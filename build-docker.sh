#!/bin/sh

export PYTHON_PYVER="$(echo "$PYTHON_SEMVER" | sed "s/\(^[0-9]\+\)\.\([0-9]\+\).*/\1\2/g")"
export BUILD_SUFFIX="${KLAYOUT_SEMVER}-py${PYTHON_PYVER}_${BUILD_NUMBER}"
export KLAYOUT_PYPI_LINK="$(grep "manylinux" klayout-pypi-links.txt | grep "$KLAYOUT_SEMVER" | grep "cp$PYTHON_PYVER" | head -1)"

if [ -z "$KLAYOUT_PYPI_LINK" ]; then
  exit 1
fi

if docker pull flaport/condalayout:"$BUILD_SUFFIX" > /dev/null 2> /dev/null; then
  exit 0 # docker image already exists... no need to rebuild. TODO: use cached docker build instead?
fi

docker build . -t flaport/condalayout:"$BUILD_SUFFIX" \
 --build-arg BUILD_NUMBER="$BUILD_NUMBER" \
 --build-arg BUILD_SUFFIX="$BUILD_SUFFIX" \
 --build-arg KLAYOUT_PYPI_LINK="$KLAYOUT_PYPI_LINK" \
 --build-arg KLAYOUT_SEMVER="$KLAYOUT_SEMVER" \
 --build-arg PYTHON_PYVER="$PYTHON_PYVER" \
 --build-arg PYTHON_SEMVER="$PYTHON_SEMVER" \
 --build-arg WORKERS="$WORKERS" && \
docker push flaport/condalayout:"$BUILD_SUFFIX"
