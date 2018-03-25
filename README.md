# linuxgsm-docker

[![CircleCI](https://circleci.com/gh/joshhsoj1902/linuxgsm-docker/tree/master.svg?style=svg)](https://circleci.com/gh/joshhsoj1902/linuxgsm-docker/tree/master)

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