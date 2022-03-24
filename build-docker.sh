#/bin/sh
if ! docker pull flaport/condalayout:$KLAYOUT_SEMVER > /dev/null 2> /dev/null; then
  export PYTHON_PYVER="$(echo "$PYTHON_SEMVER" | sed "s/\(^[0-9]\+\)\.\([0-9]\+\).*/\1\2/g")";
  export BUILD_SUFFIX="$KLAYOUT_SEMVER-$PYTHON_PYVER_$BUILD_NUMBER";
  export KLAYOUT_PYPI_LINK="$(cat klayout-pypi-links.txt | grep manylinux | grep $KLAYOUT_SEMVER | grep $PYTHON_PYVER | head -1)" && [ ! -z "$KLAYOUT_PYPI_LINK" ];
  docker build . -t flaport/condalayout:$KLAYOUT_SEMVER \
    --build-arg WORKERS=$WORKERS \
    --build-arg PYTHON_SEMVER=$PYTHON_SEMVER \
    --build-arg KLAYOUT_SEMVER=$KLAYOUT_SEMVER \
    --build-arg BUILD_NUMBER=$BUILD_NUMBER \
    --build-arg PYTHON_PYVER=$PYTHON_PYVER \
    --build-arg BUILD_SUFFIX=$BUILD_SUFFIX \
    --build-arg KLAYOUT_PYPI_LINK=$KLAYOUT_PYPI_LINK;
  docker push flaport/condalayout:$KLAYOUT_SEMVER
fi
