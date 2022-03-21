clean:
	rm -rf klayout.tar.gz
	rm -rf pkg
	rm -rf build-log.txt
	rm -rf klayout-gui

dist: docker
	docker cp `docker create flaport/condalayout:0.27.8`:/klayout/klayout-gui ./klayout-gui

docker:
	docker build . -t flaport/condalayout:0.27.8 --build-arg WORKERS=8 --build-arg PYTHON_VERSION=3.8 --build-arg KLAYOUT_VERSION=0.27.8 --build-arg BUILD_NUMBER=0 | tee build.log

rundocker:
	docker run -it flaport/condalayout:0.27.8
