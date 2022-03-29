FROM ubuntu:focal-20220105
ENV CONDA_DIR=/opt/conda
ENV DISPLAY=:0
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV LD_LIBRARY_PATH=/opt/conda/lib
ENV PATH=${CONDA_DIR}/bin:${PATH}
ENV LFLAGS=-fno-lto
ENV LDFLAGS=-fno-lto
ENV QMAKE_LFLAGS=-fno-lto
ENV QMAKE_LDFLAGS=-fno-lto
ENV LD=/opt/conda/bin/gcc
ENV CC=/opt/conda/bin/gcc
ENV CXX=/opt/conda/bin/g++

ARG BUILD_NUMBER
ARG BUILD_SUFFIX
ARG KLAYOUT_PYPI_LINK
ARG KLAYOUT_SEMVER
ARG PYTHON_PYVER
ARG PYTHON_SEMVER
ARG WORKERS

RUN printf "\
BUILD_NUMBER=$BUILD_NUMBER\n\
BUILD_SUFFIX=$BUILD_SUFFIX\n\
KLAYOUT_PYPI_LINK=$KLAYOUT_PYPI_LINK\n\
KLAYOUT_SEMVER=$KLAYOUT_SEMVER\n\
PYTHON_PYVER=$PYTHON_PYVER\n\
PYTHON_SEMVER=$PYTHON_SEMVER\n\
WORKERS=$WORKERS\n\
"

RUN ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime && \
    apt-get update && apt-get install --no-install-recommends --yes \
    build-essential \
    bzip2 \
    ca-certificates \
    ccache \
    curl \
    git \
    htop \
    htop \
    libqt5svg5-dev \
    libqt5xmlpatterns5-dev \
    neovim \
    neovim \
    openssh-client \
    patch \
    qt5-default \
    qt5-qmake \
    qtbase5-dev \
    qtltools \
    qtmultimedia5-dev \
    qttools5-dev \
    qtxmlpatterns5-dev-tools \
    rsync \
    xvfb \
    zip \
    zlib1g-dev

RUN curl -L https://github.com/conda-forge/miniforge/releases/download/4.11.0-4/Mambaforge-Linux-x86_64.sh --output /tmp/mambaforge.sh --silent && \
  /bin/bash /tmp/mambaforge.sh -b -p ${CONDA_DIR} && \
  rm /tmp/mambaforge.sh && \
  conda clean -tipsy && \
  find ${CONDA_DIR} -follow -type f -name '*.a' -delete && \
  find ${CONDA_DIR} -follow -type f -name '*.pyc' -delete && \
  conda clean -afy && \
  echo "source ${CONDA_DIR}/etc/profile.d/conda.sh && conda activate base" >> ${HOME}/.bashrc && \
  echo 'Xvfb $DISPLAY &' >> ${HOME}/.bashrc

RUN conda install -y \
    python=$PYTHON_SEMVER \
    libpython-static \
    conda-build \
    anaconda-client \
    importlib_resources=5.4.0 \
    jinja2=3.0 \
    setuptools=60 \
    gcc \
    gxx
RUN conda config --set anaconda_upload no

# clone KLayout repo
RUN git clone https://github.com/klayout/klayout --branch v$KLAYOUT_SEMVER --depth 1 /klayout
WORKDIR /klayout

# run build
RUN ./build.sh -j$WORKERS -noruby

# extract build
RUN mkdir -p _klayout-gui/bin && \
    mv bin-release _klayout-gui/lib && \
    mv _klayout-gui/lib/klayout _klayout-gui/bin/ && \
    mv _klayout-gui/lib/strm* _klayout-gui/bin/

# klayout-gui.tar.bz2
RUN mkdir /klayout/klayout-gui
WORKDIR /klayout/_klayout-gui
RUN tar -czf "/klayout/klayout-gui/klayout-gui-$BUILD_SUFFIX.tar.gz" *
WORKDIR /klayout/klayout-gui
RUN rm -rf /klayout/_klayout-gui
RUN printf "\
#! /bin/sh\n\
tar -zxf \"\$RECIPE_DIR/klayout-gui-$BUILD_SUFFIX.tar.gz\" --directory=\"\$PREFIX\"\n\
" > build.sh
RUN printf "\
{%% set name = \"klayout-gui\" %%}\n\
{%% set version = \"$KLAYOUT_SEMVER\" %%}\n\
{%% set build_number = \"$BUILD_NUMBER\" %%}\n\
{%% set path = \"./klayout-gui-$BUILD_SUFFIX.tar.gz\" %%}\n\
" > meta.yaml
ADD meta-template.yaml /meta-template.yaml
RUN cat /meta-template.yaml >> meta.yaml && cat meta.yaml
RUN conda build . && rm meta.yaml build.sh

# klayout.tar.bz2
RUN mkdir /klayout/klayout
WORKDIR /klayout/klayout
RUN printf "\
#! /bin/sh\n\
pip install --no-deps \"$KLAYOUT_PYPI_LINK\"\n\
" > build.sh && cat build.sh
RUN printf "\
{%% set name = \"klayout\" %%}\n\
{%% set version = \"$KLAYOUT_SEMVER\" %%}\n\
{%% set build_number = \"$BUILD_NUMBER\" %%}\n\
" > meta.yaml
RUN cat /meta-template.yaml >> meta.yaml && cat meta.yaml
RUN conda build . && rm meta.yaml build.sh /meta-template.yaml

# copy builds into dist
RUN mkdir /klayout/dist
RUN cp /opt/conda/conda-bld/linux-64/klayout-*.tar.bz2 /klayout/dist && cp /klayout/klayout-gui/klayout-*.tar.gz /klayout/dist
RUN conda install /klayout/dist/*.tar.bz2

WORKDIR /root
ENTRYPOINT ["bash"]
