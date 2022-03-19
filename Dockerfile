FROM condaforge/mambaforge
ENV DISPLAY=:0
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
RUN ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
RUN apt-get update && apt-get install --no-install-recommends --yes \
    build-essential zlib1g-dev qt5-default qt5-qmake libqt5svg5-dev \
    qtbase5-dev qttools5-dev qttools5-dev libqt5xmlpatterns5-dev \
    qtxmlpatterns5-dev-tools qtmultimedia5-dev ccache qtltools \
    neovim xvfb htop rsync zip
RUN mamba install -y libpython-static
ADD klayout klayout
WORKDIR klayout
RUN ./build.sh -j8 -debug -noruby -nopython #|| true
RUN rsync -av bin-debug/ /usr/bin/
RUN rsync -av bin-debug/ /usr/lib/
RUN zip -r klayout.zip bin-debug

RUN echo 'Xvfb $DISPLAY &' >> /root/.bashrc
ENTRYPOINT ["bash"]
