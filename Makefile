build:
	docker build -t joshhsoj1902/linuxgsm-docker .
start:
	docker-compose up game
stackup:
	docker stack deploy -c docker-stack.yml a
stackdown:
	docker stack rm a

.PHONY: build
