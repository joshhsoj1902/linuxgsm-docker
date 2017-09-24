FROM ubuntu:16.04

# Stop apt-get asking to get Dialog frontend
ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

# Install dependencies and clean
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y \
        binutils \
        bsdmainutils \
        bzip2 \
        curl \
        file \
        git \
        gzip \
        lib32gcc1 \
        lib32ncurses5 \
        lib32z1 \
        libc6 \
        libstdc++6 \
        libstdc++6:i386 \
        mailutils \
        postfix \
        python \
        tmux \
        util-linux \
        unzip \
        wget && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    rm -rf /var/tmp/*

# Add the steam user
RUN adduser \
    --disabled-login \
    --disabled-password \
    --shell /bin/bash \
    steam

RUN usermod -G tty steam

RUN mkdir -p /home/steam/linuxgsm \
  && chown -R steam:steam /home/steam

# Select the script as entry point
#COPY ./update-linuxgsm.sh /home/steam/
#RUN [ -d /home/steam/linuxgsm ] || mkdir -p /home/steam/linuxgsm && \
#    chown -R steam:steam /home/steam && \
#    chmod u+x /home/steam/update-linuxgsm.sh

# Switch to the user steam
USER steam

WORKDIR /home/steam/linuxgsm

# Install LinuxGSM
RUN git clone "https://github.com/GameServerManagers/LinuxGSM.git" /home/steam/linuxgsm

RUN git fetch --all \
 && git reset --hard origin/master

RUN git checkout tags/170710.1

RUN find /home/steam/linuxgsm -type f -name "*.sh" -exec chmod u+x {} \; \
 && find /home/steam/linuxgsm -type f -name "*.py" -exec chmod u+x {} \; \
 && chmod u+x /home/steam/linuxgsm/lgsm/functions/README.md

RUN  mkdir ~/bin \
  && curl -sSLf -z ~/bin/gomplate -o ~/bin/gomplate https://github.com/hairyhenderson/gomplate/releases/download/v2.0.0/gomplate_linux-amd64-slim \
  && chmod 755 ~/bin/gomplate

ADD docker-runner.sh docker-health.sh ./

CMD chmod 777 docker-runner.sh docker-health.sh

HEALTHCHECK --start-period=45s CMD ./docker-health.sh

CMD ["bash", "./docker-runner.sh"]
