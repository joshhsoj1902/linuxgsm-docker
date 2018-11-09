build:
	docker build -t joshhsoj1902/linuxgsm-docker .
	docker tag joshhsoj1902/linuxgsm-docker:latest joshhsoj1902/linuxgsm-docker:local
start:
	docker-compose up game
stackup:
	docker stack deploy -c docker-stack.yml a
stackdown:
	docker stack rm a

test:
	./scripts/test-gomplate.sh

.PHONY: build
