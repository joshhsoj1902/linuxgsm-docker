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
| LGSM_IP                |                                        |                             | All              |
| LGSM_MAXPLAYERS        | Not tested |||
| LGSM_JAVARAM           | || Minecraft |
| LGSM_DEFAULTMAP        | Not tested || Gmod |
| LGSM_GAMEMODE          | Not tested || Gmod |
| LGSM_WORKSHOPAUTH      | Not tested || Gmod |
| LGSM_WORKSHOPCOLLECTIONID | Not tested ||Gmod|
| LGSM_ANSI              | Not tested |||
| LGSM_BRANCH            | Not tested |||
| LGSM_EMAILALERT        | Not tested |||
| LGSM_EMAIL             | Not tested |||
| LGSM_EMAILFROM         | Not tested |||
| LGSM_PUSHBULLETALERT   | Not tested |||
| LGSM_PUSHBULLETTOKEN   | Not tested |||
| LGSM_CHANNELTAG        | Not tested |||
| LGSM_UPDATEONSTART     | Not tested |||
| LGSM_MAXBACKUPS        | Not tested |||
| LGSM_MAXBACKUPDAYS     | Not tested |||
| LGSM_STOPONBACKUP      | Not tested |||
| LGSM_CONSOLELOGGING    | Not tested |||
| LGSM_LOGDAYS           | Not tested |||


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
