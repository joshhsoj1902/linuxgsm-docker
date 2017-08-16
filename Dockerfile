FROM cyrale/linuxgsm

WORKDIR /home/steam/linuxgsm

RUN git fetch --all && git reset --hard origin/master

RUN git checkout tags/170710.1
