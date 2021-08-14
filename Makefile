GO := go

COMMIT ?= `git rev-parse --short HEAD 2>/dev/null`
VERSION ?= `git describe --abbrev=0 --tags $(git rev-list --tags --max-count=1) 2>/dev/null | sed 's/v\(.*\)/\1/'`
BUILD_DATE ?= `date -u +"%Y-%m-%dT%H:%M:%SZ"`

COMMIT_FLAG := -X `go list ./src/version`.GitCommit=$(COMMIT)
VERSION_FLAG := -X `go list ./src/version`.Version=$(VERSION)
BUILD_DATE_FLAG := -X `go list ./src/version`.BuildDate=$(BUILD_DATE)

GOOS ?= $(shell go version | sed 's/^.*\ \([a-z0-9]*\)\/\([a-z0-9]*\)/\1/')
GOARCH ?= $(shell go version | sed 's/^.*\ \([a-z0-9]*\)\/\([a-z0-9]*\)/\2/')

build:
	@docker build \
		--compress \
		-f Dockerfile \
		-t joshhsoj1902/linuxgsm-docker \
		.
	docker tag joshhsoj1902/linuxgsm-docker:latest joshhsoj1902/linuxgsm-docker:local
start:
	docker-compose up game
stackup:
	docker stack deploy -c docker-stack.yml a
stackdown:
	docker stack rm a

build-monitor:
	GOOS=$(shell echo $* | cut -f1 -d-) GOARCH=$(shell echo $* | cut -f2 -d- | cut -f1 -d.) CGO_ENABLED=0 \
		$(GO) build \
			-ldflags "-w -s $(COMMIT_FLAG) $(VERSION_FLAG) $(BUILD_DATE_FLAG)" \
			-o monitor \
			./src/cmd/monitor/monitor.go

test:
	./scripts/test-gomplate.sh

.PHONY: build
