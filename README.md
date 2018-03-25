# linuxgsm-docker

[![CircleCI](https://circleci.com/gh/joshhsoj1902/linuxgsm-docker/tree/master.svg?style=svg)](https://circleci.com/gh/joshhsoj1902/linuxgsm-docker/tree/master)

## Options
This image uses environment variables for configuration, below is a list of the supported environment variables

| Environment Variable   | Description                            | Options               | Supported Games |
|------------------------|----------------------------------------|-----------------------|-----------------|
| LGSM_GAMESERVERNAME    | LGSM name of the game to install       |                       |All              |
| LGSM_UPDATEINSTALLSKIP | What sort of intall to do on startup   | UPDATE, INSTALL, SKIP |All              |
| LGSM_PORT              | Port to bind to                        |                       |All              |


## Usage

### Counter strike source
```
version: '3.1'
services:
  game:
    image: joshhsoj1902/linuxgsm-docker:latest
    environment:
      - LGSM_GAMESERVERNAME=cssserver
      - LGSM_UPDATEINSTALLSKIP=UPDATE
    volumes:
      - "/home/steam/linuxgsm/logs"
```