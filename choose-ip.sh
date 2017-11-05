#!/bin/bash
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
else
    export LGSM_IP=$(hostname -i)
fi
echo 'IP SET TO '$LGSM_IP
