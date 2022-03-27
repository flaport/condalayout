clean:
	rm -rf klayout.tar.gz
	rm -rf pkg
	rm -rf build-log.txt
	rm -rf klayout-gui

dist: docker
	docker cp `docker create flaport/condalayout:0.27.8`:/klayout/klayout-gui ./klayout-gui

docker:
	docker build . -t flaport/condalayout:0.27.8-py39_0 \
		--build-arg WORKERS=8 \
		--build-arg PYTHON_SEMVER=3.9 \
		--build-arg KLAYOUT_SEMVER=0.27.8 \
		--build-arg BUILD_NUMBER=0 \
		--build-arg PYTHON_PYVER=39 \
		--build-arg BUILD_SUFFIX=0.27.8-py39_0 \
		--build-arg KLAYOUT_PYPI_LINK="https://files.pythonhosted.org/packages/ae/66/62e2adf48f82bb1672e51f3e3c2992ef5d8ade229e2a6acfc2d4f39961f1/klayout-0.27.8-cp39-cp39-manylinux_2_17_x86_64.manylinux2014_x86_64.whl"

rundocker:
	docker run -it flaport/condalayout:0.27.8-py39_0
