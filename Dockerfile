FROM cyrale/linuxgsm

WORKDIR /home/steam/linuxgsm

RUN git fetch --all \
 && git reset --hard origin/master

RUN find . -type f -name "*.sh" -exec chmod u+x {} \; \
 && find . -type f -name "*.py" -exec chmod u+x {} \; \
 && chmod u+x ./lgsm/functions/README.md

RUN git checkout tags/170710.1
