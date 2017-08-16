build:
	docker build -t joshhsoj1902/linuxgsm-docker .
start:
	docker run --rm joshhsoj1902/linuxgsm-docker:latest

.PHONY: build
