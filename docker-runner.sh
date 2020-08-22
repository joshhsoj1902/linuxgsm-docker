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

./monitor &

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
      ./lgsm-gameserver auto-install || true
      exitcode="$?"

      if [ "$exitcode" -gt "0" ] && [ "$exitcode" != "3" ]; then
        # Retry once 
        echo "Unexpected error when updating ($exitcode). Trying again."
        ./lgsm-gameserver auto-install || true
        exitcode="$?"
      fi

      rm -f INSTALLING.LOCK
      
      if [ "$exitcode" != "0" ] && [ "$exitcode" != "3" ]; then
        # exitcode 3 is a warning, in this case the warning we don't care about is steam not being installed
        # any other thing not being installed is an issue, but steam will be installed if it's missing.
        # we can't use the one in apt-get for some reason (it installs but it always hangs installing games) 
        echo "Unexpected exit code during install $exitcode"
        exit $exitcode
      fi

      echo "Game has been updated. Starting"
      ;;
  "INSTALL")
      touch INSTALLING.LOCK  
      ./linuxgsm.sh $LGSM_GAMESERVERNAME
      mv $LGSM_GAMESERVERNAME lgsm-gameserver || true
      ls -ltr
      ./lgsm-gameserver auto-install || true
      exitcode="$?"

      if [ "$exitcode" -gt "0" ] && [ "$exitcode" != "3" ]; then
        # Retry once 
        echo "Unexpected error when installing ($exitcode). Trying again."
        ./lgsm-gameserver auto-install || true
        exitcode="$?"
      fi

      echo "Install returned code $exitcode"
      rm -f INSTALLING.LOCK
       
      if [ "$exitcode" != "0" ] && [ "$exitcode" != "3" ]; then
        # exitcode 3 is a warning, in this case the warning we don't care about is steam not being installed
        # any other thing not being installed is an issue, but steam will be installed if it's missing.
        # we can't use the one in apt-get for some reason (it installs but it always hangs installing games) 
        echo "Unexpected exit code during uninstall $exitcode"
        exit $exitcode
      fi

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
