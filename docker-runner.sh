#!/bin/bash

rm -f INSTALLING.LOCK

if [ -z "$LGSM_GAMESERVERNAME" ]; then
  echo "Need to set LGSM_GAMESERVERNAME environment"
  exit 1
fi

echo "IP is set to "${LGSM_IP}

mkdir -p ~/linuxgsm/lgsm/config-lgsm/$LGSM_GAMESERVERNAME
gomplate -f ~/linuxgsm/lgsm/config-default/config-lgsm/common.cfg.tmpl -o ~/linuxgsm/lgsm/config-lgsm/$LGSM_GAMESERVERNAME/common.cfg
if [ -f ~/linuxgsm/lgsm/config-lgsm/$LGSM_GAMESERVERNAME/$LGSM_GAMESERVERNAME.cfg.tmpl ]; then
  gomplate -f ~/linuxgsm/lgsm/config-lgsm/$LGSM_GAMESERVERNAME/$LGSM_GAMESERVERNAME.cfg.tmpl -o ~/linuxgsm/lgsm/config-lgsm/$LGSM_GAMESERVERNAME/$LGSM_GAMESERVERNAME.cfg
fi
echo "DONE GOMPLATING"

if [ -n "$LGSM_UPDATEINSTALLSKIP" ]; then
  case "$LGSM_UPDATEINSTALLSKIP" in
  "UPDATE")
      touch INSTALLING.LOCK
      ./linuxgsm.sh $LGSM_GAMESERVERNAME
      mv $LGSM_GAMESERVERNAME lgsm-gameserver
      ./lgsm-gameserver auto-install
      rm -f INSTALLING.LOCK
      
      echo "Game has been updaed. Starting"
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

tail -F /home/steam/linuxgsm/log/console/lgsm-gameserver-console.log -F /home/steam/linuxgsm/log/script/lgsm-gameserver-script.log -F /home/steam/linuxgsm/log/script/lgsm-gameserver-alert.log
#
while :
do
./lgsm-gameserver monitor
sleep 30s
done
