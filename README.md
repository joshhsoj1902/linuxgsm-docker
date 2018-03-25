[![CircleCI][circle-image]][circle-url]

# linuxgsm-docker

Dockerized version of the [Linux Game Server Manager][lgsm-home] project

## Options
This image uses environment variables for configuration, below is a list of the supported environment variables

| Environment Variable   | Description                            | Options                     | Supported Games  |
|------------------------|----------------------------------------|-----------------------------|------------------|
| LGSM_GAMESERVERNAME    | Name of the game to install            | [LGSM Configs][lgsm-config] | All              |
| LGSM_UPDATEINSTALLSKIP | What sort of intall to do on startup   | UPDATE, INSTALL, SKIP       | All              |
| LGSM_PORT              | Port to bind to                        |                             | All              |


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

[circle-image]: https://circleci.com/gh/joshhsoj1902/linuxgsm-docker/tree/master.svg?style=svg
[circle-url]: https://circleci.com/gh/joshhsoj1902/linuxgsm-docker/tree/master
[lgsm-config]: https://github.com/GameServerManagers/LinuxGSM/tree/master/lgsm/config-default/config-lgsm
[lgsm-home]: https://github.com/GameServerManagers/LinuxGSM