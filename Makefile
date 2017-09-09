build:
	docker build -t joshhsoj1902/linuxgsm-docker .
start:
	docker-compose up game

.PHONY: build
