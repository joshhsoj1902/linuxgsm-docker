FROM ubuntu:16.04@sha256:689aa49d87d325f951941d789f7f7c8fae3394490cbcf084144caddba9c1be12

WORKDIR /home/steam/linuxgsm

# Stop apt-get asking to get Dialog frontend
ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

# Install dependencies and clean
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y \
        bc \
        binutils \
        bsdmainutils \
        bzip2 \
        curl \
        default-jre \
        expect \
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
        net-tools \
        postfix \
        python \
        tmux \
        telnet \
        util-linux \
        unzip \
        wget

# Debug tools
RUN apt-get install -y netcat iputils-ping dnsutils traceroute iptables vim

# Cleanup 
RUN apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    rm -rf /var/tmp/*

RUN  mkdir ~/bin \
  && curl -sSLf -z /usr/bin/gomplate -o /usr/bin/gomplate https://github.com/hairyhenderson/gomplate/releases/download/v2.2.0/gomplate_linux-amd64-slim \
  && chmod 755 /usr/bin/gomplate

# Add the steam user
RUN adduser \
    --disabled-login \
    --disabled-password \
    --shell /bin/bash \
    --gecos "" \
    steam

RUN usermod -G tty steam

RUN chown -R steam:steam /home/steam

# Switch to the user steam
USER steam

# Install LinuxGSM
RUN git clone "https://github.com/GameServerManagers/LinuxGSM.git" /home/steam/linuxgsm 

# Install GameConfigs
RUN git clone "https://github.com/GameServerManagers/Game-Server-Configs.git" /home/steam/linuxgsm-configs

# RUN git fetch --all \
#  && git reset --hard origin/master

RUN git checkout tags/180318.1

USER root 
 
RUN find /home/steam/linuxgsm -type f -name "*.sh" -exec chmod u+x {} \; \
 && find /home/steam/linuxgsm -type f -name "*.py" -exec chmod u+x {} \; \
 && chmod u+x /home/steam/linuxgsm/lgsm/functions/README.md

ADD common.cfg.tmpl ./lgsm/config-default/config-lgsm/

RUN chown -R steam:steam /home/steam/linuxgsm \
 && chmod -R 777 /home/steam/linuxgsm \
 && ls -ltr

ADD docker-runner.sh docker-health.sh docker-ready.sh ./

RUN chown steam:steam docker-runner.sh docker-health.sh docker-ready.sh \
 && chmod +x docker-runner.sh docker-health.sh docker-ready.sh

ADD functions/*.sh /home/steam/linuxgsm/lgsm/functions/

ADD custom_configs/ /home/steam/linuxgsm-configs

RUN chown steam:steam /home/steam/linuxgsm/lgsm/functions/*.sh \
 && chown -R steam:steam /home/steam/linuxgsm-configs \
 && chmod +x /home/steam/linuxgsm/lgsm/functions/*.sh

USER steam

RUN mkdir logs serverfiles serverfiles/Saves

# HEALTHCHECK --start-period=30s CMD ./docker-health.sh

CMD ["bash", "./docker-runner.sh"]
