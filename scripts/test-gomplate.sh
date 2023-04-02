#!/bin/bash

docker run --rm joshhsoj1902/linuxgsm-docker:latest gomplate -f ./lgsm/config-default/config-lgsm/common.cfg.tmpl

#Custom Configs
echo "\n=============\n==MINECRAFT==\n============="
docker run --rm joshhsoj1902/linuxgsm-docker:latest gomplate -f /home/linuxgsm/linuxgsm/lgsm/config-default/config-game-template/Minecraft/server.properties.tmpl
echo "\n========\n==7dtd==\n========"
docker run --rm joshhsoj1902/linuxgsm-docker:latest gomplate -f /home/linuxgsm/linuxgsm/lgsm/config-default/config-game-template/7DaysToDie/serverconfig.xml.tmpl
echo "\n==========\n==Mumble==\n=========="
docker run --rm joshhsoj1902/linuxgsm-docker:latest gomplate -f /home/linuxgsm/linuxgsm/lgsm/config-default/config-game-template/7DaysToDie/serverconfig.xml.tmpl