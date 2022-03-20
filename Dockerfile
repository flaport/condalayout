FROM condaforge/mambaforge

ENV DISPLAY=:0
ENV PYTHON_VERSION=3.8
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV LD_LIBRARY_PATH=/opt/conda/lib

RUN ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
RUN apt-get update && apt-get install --no-install-recommends --yes \
    build-essential zlib1g-dev qt5-default qt5-qmake libqt5svg5-dev \
    qtbase5-dev qttools5-dev qttools5-dev libqt5xmlpatterns5-dev \
    qtxmlpatterns5-dev-tools qtmultimedia5-dev ccache qtltools \
    neovim xvfb htop rsync zip
RUN mamba install -y python=$PYTHON_VERSION libpython-static

ADD klayout klayout
WORKDIR klayout

RUN ./build.sh -j8 -noruby
#-pylib $CONDA_PREFIX/lib/libpython$PYTHON_VERSION.so -pyinc $CONDA_PREFIX/include/python$PYTHON_VERSION

RUN find ./bin-release -type f | grep so | xargs -I {} cp {} /usr/lib/ && \
    cp ./bin-release/klayout /usr/bin/_klayout && \
    echo '#! /bin/sh\nexport LD_LIBRARY_PATH="$CONDA_PREFIX/lib"\n$CONDA_PREFIX/bin/_klayout "$@"' > /usr/bin/klayout && \
    chmod +x /usr/bin/klayout

RUN zip -r klayout.zip pkg && \
    rsync -av ./pkg/bin/ /opt/conda/bin/ && \
    rsync -av ./pkg/lib/ /opt/conda/lib/

RUN rsync -av bin-release/ /usr/bin/ && rsync -av bin-release/ /usr/lib/

RUN echo 'Xvfb $DISPLAY &' >> /root/.bashrc
ENTRYPOINT ["bash"]
