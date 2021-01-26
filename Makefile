.PHONY: all

all: docker

docker: docker-build docker-tag docker-push

docker-build:
	docker build --no-cache -t mongo_backup .

docker-tag:
	docker tag mongo_backup:latest hoistudio/mongo_backup:latest

docker-push:
	docker push hoistudio/mongo_backup:latest
