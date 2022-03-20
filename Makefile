clean:
	rm -rf klayout.tar.gz
	rm -rf pkg
	rm -rf build-log.txt

dist: docker
	docker cp `docker create kl`:/klayout/klayout.tar.gz ./

docker:
	docker build . -t kl | tee build.log

rundocker:
	docker run -it kl
