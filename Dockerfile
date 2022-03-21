FROM condaforge/mambaforge

ARG WORKERS
ARG PYTHON_VERSION
ARG KLAYOUT_VERSION

ENV DISPLAY=:0
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV LD_LIBRARY_PATH=/opt/conda/lib

RUN ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
RUN apt-get update && apt-get install --no-install-recommends --yes \
    build-essential zlib1g-dev qt5-default qt5-qmake libqt5svg5-dev \
    qtbase5-dev qttools5-dev qttools5-dev libqt5xmlpatterns5-dev \
    qtxmlpatterns5-dev-tools qtmultimedia5-dev ccache qtltools git \
    neovim xvfb htop rsync zip
RUN mamba install -y python=$PYTHON_VERSION libpython-static

RUN git clone https://github.com/klayout/klayout --branch v$KLAYOUT_VERSION --depth 1
WORKDIR klayout

RUN ./build.sh -j$WORKERS -noruby

RUN mkdir -p klayout/bin klayout/lib && \
    rsync -av bin-release/ klayout/lib/ && \
    mv klayout/lib/klayout klayout/bin/_klayout && \
    mv klayout/lib/strm* klayout/bin/ && \
    echo '#! /bin/sh\nexport LD_LIBRARY_PATH="$CONDA_PREFIX/lib"\nexec _klayout "$@"' > klayout/bin/klayout && \
    chmod u+x klayout/bin/klayout && \
    rsync -av klayout/ /opt/conda/

WORKDIR /klayout/klayout
ADD canonical_name.py /canonical_name.py
RUN mkdir /klayout/klayout-gui
RUN tar -czf "/klayout/klayout-gui/$(python /canonical_name.py klayout-gui -v $KLAYOUT_VERSION -n 0 -e tar.gz)" *

WORKDIR /klayout/klayout-gui
RUN echo "#! /bin/sh\ntar -zxf \"\$RECIPE_DIR/$(python /canonical_name.py klayout-gui -v $KLAYOUT_VERSION -n 0 -e tar.gz)\" --directory=\"\$PREFIX\"" > build.sh
ADD meta.yaml meta.yaml
RUN sed -i "s/path: \.\.\/klayout.tar.gz/path: \.\/$(python /canonical_name.py klayout-gui -v $KLAYOUT_VERSION -n 0 -e tar.gz)/g" meta.yaml
RUN cat meta.yaml
RUN conda install -y conda-build
RUN conda build .
RUN cp /opt/conda/conda-bld/linux-64/klayout-gui-* ./

WORKDIR /root
RUN echo 'Xvfb $DISPLAY &' >> /root/.bashrc
ENTRYPOINT ["bash"]
