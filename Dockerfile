FROM cyrale/linuxgsm

WORKDIR /home/steam/linuxgsm

RUN git fetch --all && git reset --hard origin/master

RUN git checkout tags/170710.1

RUN  mkdir ~/bin \
  && curl -sSLf -z ~/bin/gomplate -o ~/bin/gomplate https://github.com/hairyhenderson/gomplate/releases/download/v2.0.0/gomplate_linux-amd64-slim \
  && chmod 755 ~/bin/gomplate

#ADD docker-runner.sh ./

#CMD ["bash", "./docker-runner.sh"]
