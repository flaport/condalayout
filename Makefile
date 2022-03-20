clean:
	rm -rf klayout.zip
	rm -rf klayout
	rm -rf pkg
	rm -rf build-log.txt

dist: docker
	docker cp `docker create kl`:/klayout/klayout.zip ./

docker:
	if [ ! -d klayoutgit ]; then git clone git@github.com:flaport/klayout klayoutgit; fi
	rm -rf klayout && rsync -av ./klayoutgit/ ./klayout/
	#docker buildx build . -t kl
	docker build . -t kl | tee build.log

rundocker:
	docker run -it kl