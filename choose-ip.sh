#!/bin/bash
echo 'LGSM_IP 1 '$LGSM_IP

if [[ -n "${bind_gateway}" ]]; then
    matchIP=`echo ${bind_gateway} | cut -d"." -f1-3`.*
    IFS=' ' read -r -a ips <<< $(hostname -I)
    for element in "${ips[@]}"
    do
        if [[ $element == $matchIP ]]; then
            echo 'MATCH '$element
            export LGSM_IP=$element            
        fi
    done
fi

echo 'LGSM_IP 2 '$LGSM_IP

if [[ -z "$LGSM_IP" && -n "${bind_overlay}" && -n "${bind_ingress}" ]]; then
    IFS=' ' read -r -a ips <<< $(hostname -I)
    for element in "${ips[@]}"
    do
        if [[ $element != $matchOverlayIP && $element != $matchIngressIP ]]; then
            echo 'N-MATCH '$element
            export LGSM_IP=$element            
        fi
    done
fi

echo 'LGSM_IP 3 '$LGSM_IP


if [ -z "$LGSM_IP" ]; then
  export LGSM_IP=$(hostname -i)
fi
echo 'IP SET TO '$LGSM_IP
