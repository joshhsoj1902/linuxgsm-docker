#!/bin/bash

docker run --rm joshhsoj1902/linuxgsm-docker:latest gomplate -f ./lgsm/config-default/config-lgsm/common.cfg.tmpl

#Custom Configs
echo "\n=============\n==MINECRAFT==\n============="
docker run --rm joshhsoj1902/linuxgsm-docker:latest gomplate -f ../linuxgsm-configs/Minecraft/server.properties.tmpl
echo "\n========\n==7dtd==\n========"            
docker run --rm joshhsoj1902/linuxgsm-docker:latest gomplate -f ../linuxgsm-configs/7DaysToDie/serverconfig.xml.tmpl
echo "\n==========\n==Mumble==\n=========="            
docker run --rm joshhsoj1902/linuxgsm-docker:latest gomplate -f ../linuxgsm-configs/7DaysToDie/serverconfig.xml.tmpl