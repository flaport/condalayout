docker:
	if [ ! -d klayoutgit ]; then git clone git@github.com:flaport/klayout klayoutgit; fi
	rm -rf klayout && rsync -av ./klayoutgit/ ./klayout/
	docker buildx build . -t kl

dockerrun:
	docker run -it kl
