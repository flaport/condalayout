# CondaLayout

> Conda + KLayout

An attempt to enable a conda-install for [KLayout](https://klayout.de). Currently
only for Linux and python 3.8 (I will add more python versions in the future).

## Installation

To install the normal klayout python package:
```sh
conda install -c flaport klayout
```

To install the KLayout **GUI** within your conda environment:
```sh
conda install -c flaport klayout-gui
```
The advantage of installing the KLayout GUI within your conda environment is that you can `conda install` any dependency (numpy, matplotlib, scipy, ...) for your macros without polluting your system python with a multitude of packages. **Note:** the klayout-gui package is currently being built *without* ruby support (I might also add this in the future).
