FROM condaforge/mambaforge

ARG WORKERS
ARG PYTHON_VERSION
ARG KLAYOUT_VERSION
ARG BUILD_NUMBER

ENV DISPLAY=:0
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV LD_LIBRARY_PATH=/opt/conda/lib

RUN ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
RUN apt-get update && apt-get install --no-install-recommends --yes \
    build-essential zlib1g-dev qt5-default qt5-qmake libqt5svg5-dev \
    qtbase5-dev qttools5-dev qttools5-dev libqt5xmlpatterns5-dev \
    qtxmlpatterns5-dev-tools qtmultimedia5-dev ccache qtltools git \
    neovim xvfb htop rsync zip

RUN mamba install -y python=$PYTHON_VERSION libpython-static conda-build anaconda-client
RUN conda config --set anaconda_upload no
ADD canonical_name.py /canonical_name.py
ADD meta.yaml /meta-template.yaml

RUN git clone https://github.com/klayout/klayout --branch v$KLAYOUT_VERSION --depth 1
WORKDIR klayout

RUN ./build.sh -j$WORKERS -noruby

RUN mkdir -p klayout/bin klayout/lib && \
    rsync -av bin-release/ klayout/lib/ && \
    mv klayout/lib/klayout klayout/bin/ && \
    mv klayout/lib/strm* klayout/bin/ && \
    rsync -av klayout/ /opt/conda/

# klayout-gui.tar.bz2
RUN mkdir /klayout/klayout-gui
WORKDIR /klayout/klayout
RUN tar -czf "/klayout/klayout-gui/$(python /canonical_name.py klayout-gui -v $KLAYOUT_VERSION -n $BUILD_NUMBER -e tar.gz)" *
WORKDIR /klayout/klayout-gui
RUN rm -rf /klayout/klayout
RUN echo "#! /bin/sh\ntar -zxf \"\$RECIPE_DIR/$(python /canonical_name.py klayout-gui -v $KLAYOUT_VERSION -n $BUILD_NUMBER -e tar.gz)\" --directory=\"\$PREFIX\"" > build.sh
RUN echo "{% set name = \"klayout-gui\" %}\n{% set version = \"$KLAYOUT_VERSION\" %}\n{% set python = \"py$(python -c 'import sys; print(f"{sys.version_info.major}{sys.version_info.minor}")')\" %}\n{% set build_number = \"$BUILD_NUMBER\" %}" > meta.yaml
RUN cat /meta-template.yaml >> meta.yaml && cat meta.yaml
RUN conda build . && rm meta.yaml build.sh

# klayout.tar.bz2
RUN mkdir /klayout/klayout-py
WORKDIR /klayout/klayout-py
RUN echo "#! /bin/sh\npip install --no-deps https://files.pythonhosted.org/packages/2f/f6/3489ecf80db79a879f088a5abf40c48b7a9c6641114609376ae777859cf8/klayout-0.27.8-cp38-cp38-manylinux_2_17_x86_64.manylinux2014_x86_64.whl" > build.sh && cat build.sh
RUN echo "{% set name = \"klayout\" %}\n{% set version = \"$KLAYOUT_VERSION\" %}\n{% set python = \"py$(python -c 'import sys; print(f"{sys.version_info.major}{sys.version_info.minor}")')\" %}\n{% set build_number = \"$BUILD_NUMBER\" %}" > meta.yaml
RUN cat /meta-template.yaml >> meta.yaml && cat meta.yaml
RUN conda build . && rm meta.yaml build.sh /meta-template.yaml

# copy builds into dist
RUN mkdir /klayout/dist
RUN cp /opt/conda/conda-bld/linux-64/klayout-* /klayout/dist

WORKDIR /root
RUN echo 'Xvfb $DISPLAY &' >> /root/.bashrc
ENTRYPOINT ["bash"]
