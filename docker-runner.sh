#!/bin/bash

set -e

cleanup() {
  echo "Exit received"

  echo "Stopping server"
  ./lgsm-gameserver stop
  echo "Server Stopped"

  echo "Shutting down"
  exit 0
}

trap 'cleanup' SIGINT SIGTERM

for f in startup-scripts/*.sh; do
  bash "$f" -H || break
done

#Set ENV defaults
if [ -n "$LGSM_PORT" ]; then
  if [ -z "$LGSM_CLIENTPORT" ]; then
    clientport=$(($LGSM_PORT-10))
    echo "clientPort $clientport"
    export LGSM_CLIENTPORT=$clientport
  fi
  if [ -z "$LGSM_SOURCETVPORT" ]; then
    sourcetvport=$(($LGSM_PORT+5))
    echo "sourcetvport $sourcetvport"
    export LGSM_SOURCETVPORT=$sourcetvport
  fi
fi

parse-env --env "LGSM_" > env.json

rm -f INSTALLING.LOCK

if [ -z "$LGSM_GAMESERVERNAME" ]; then
  echo "Need to set LGSM_GAMESERVERNAME environment"
  exit 1
fi

echo "IP is set to "${LGSM_IP}

echo "Gomplating main config"
mkdir -p ~/linuxgsm/lgsm/config-lgsm/$LGSM_GAMESERVERNAME
gomplate -d env=~/linuxgsm/env.json -f ~/linuxgsm/lgsm/config-default/config-lgsm/common.cfg.tmpl -o ~/linuxgsm/lgsm/config-lgsm/$LGSM_GAMESERVERNAME/common.cfg
if [ -f ~/linuxgsm/lgsm/config-lgsm/$LGSM_GAMESERVERNAME/$LGSM_GAMESERVERNAME.cfg.tmpl ]; then
  gomplate -d env=~/linuxgsm/env.json -f ~/linuxgsm/lgsm/config-lgsm/$LGSM_GAMESERVERNAME/$LGSM_GAMESERVERNAME.cfg.tmpl -o ~/linuxgsm/lgsm/config-lgsm/$LGSM_GAMESERVERNAME/$LGSM_GAMESERVERNAME.cfg
fi

echo "Gomplating game configs"
for d in /home/linuxgsm/linuxgsm/lgsm/config-default/config-game-template/*/ ; do
    configGameFolder=$(basename $d)
    for f in $d/*.tmpl ; do
      configGameFile=$(basename $f)
      outputConfigGameFile=$(basename $f .tmpl)
      outputFile="/home/linuxgsm/linuxgsm/lgsm/config-default/config-game/$configGameFolder/$outputConfigGameFile"
      gomplate -f $f -o $outputFile
		  chmod u+x,g+x $outputFile
    done
done

echo "DONE GOMPLATING"

if [ -n "$LGSM_UPDATEINSTALLSKIP" ]; then
  case "$LGSM_UPDATEINSTALLSKIP" in
  "UPDATE")
      touch INSTALLING.LOCK
      ./linuxgsm.sh $LGSM_GAMESERVERNAME
      mv $LGSM_GAMESERVERNAME lgsm-gameserver
      ./lgsm-gameserver auto-install
      rm -f INSTALLING.LOCK
      
      echo "Game has been updated. Starting"
      ;;
  "INSTALL")
      touch INSTALLING.LOCK  
      ./linuxgsm.sh $LGSM_GAMESERVERNAME
      mv $LGSM_GAMESERVERNAME lgsm-gameserver
      ls -ltr
      ./lgsm-gameserver auto-install
      rm -f INSTALLING.LOCK
       
      echo "Game has been installed. Exiting"
      exit
      ;;
  esac
fi

if [ ! -f lgsm-gameserver ]; then
    echo "No game is installed, please set LGSM_UPDATEINSTALLSKIP"
    exit 1
fi

# # configure game-specfic settings
# gomplate -f ${servercfgfullpath}.tmpl -o ${servercfgfullpath}   // I can't predict what the filename is. 

#
./lgsm-gameserver start
sleep 30s
#

./lgsm-gameserver details
sleep 5s
./lgsm-gameserver monitor

if [ "$LGSM_CONSOLE_STDOUT" == "true" ]; then
  tail -F ~/linuxgsm/log/console/lgsm-gameserver-console.log &
fi

if [ "$LGSM_SCRIPT_STDOUT" == "true" ]; then
  tail -F ~/linuxgsm/log/script/lgsm-gameserver-script.log &
fi

if [ "$LGSM_ALERT_STDOUT" == "true" ]; then
  tail -F ~/linuxgsm/log/script/lgsm-gameserver-alert.log &
fi

if [ "$LGSM_GAME_STDOUT" == "true" ]; then
  tail -F ~/linuxgsm/log/server/output_log*.txt &
fi

wait $!
