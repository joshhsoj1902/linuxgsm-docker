#!/bin/bash

export bind_gateway=`docker network inspect --format='{{ (index .IPAM.Config 0).Gateway }}' docker_gwbridge`

echo 'THE GW '$bind_gateway