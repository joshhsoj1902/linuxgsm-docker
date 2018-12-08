FROM ubuntu:18.04

WORKDIR /home/linuxgsm/linuxgsm

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
        jq \
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

COPY --from=joshhsoj1902/parse-env:1.0.2 /go/src/github.com/joshhsoj1902/parse-env/main /usr/bin/parse-env
COPY --from=hairyhenderson/gomplate:v3.1.0-alpine /bin/gomplate /usr/bin/gomplate

# Add the linuxgsm user
RUN adduser \
    --disabled-login \
    --disabled-password \
    --shell /bin/bash \
    --gecos "" \
    linuxgsm
RUN usermod -G tty linuxgsm
RUN chown -R linuxgsm:linuxgsm /home/linuxgsm

# Switch to the user linuxgsm
USER linuxgsm

# Install LinuxGSM
RUN git clone "https://github.com/GameServerManagers/LinuxGSM.git" /home/linuxgsm/linuxgsm \
 && git checkout tags/181124

# Install GameConfigs
RUN git clone "https://github.com/GameServerManagers/Game-Server-Configs.git" /home/linuxgsm/linuxgsm-configs

# RUN git fetch --all \
#  && git reset --hard origin/master

# RUN git checkout tags/180908.1

USER root 
 
RUN find /home/linuxgsm/linuxgsm -type f -name "*.sh" -exec chmod u+x {} \; \
 && find /home/linuxgsm/linuxgsm -type f -name "*.py" -exec chmod u+x {} \; \
 && chmod u+x /home/linuxgsm/linuxgsm/lgsm/functions/README.md

ADD common.cfg.tmpl ./lgsm/config-default/config-lgsm/
RUN chown -R linuxgsm:linuxgsm /home/linuxgsm/linuxgsm \
 && chmod -R 777 /home/linuxgsm/linuxgsm \
 && ls -ltr

ADD docker-runner.sh docker-health.sh docker-ready.sh ./
RUN chown linuxgsm:linuxgsm docker-runner.sh docker-health.sh docker-ready.sh \
 && chmod +x docker-runner.sh docker-health.sh docker-ready.sh

ADD functions/* /home/linuxgsm/linuxgsm/lgsm/functions/
ADD custom_configs/ /home/linuxgsm/linuxgsm-configs
RUN chown linuxgsm:linuxgsm /home/linuxgsm/linuxgsm/lgsm/functions/* \
 && chown -R linuxgsm:linuxgsm /home/linuxgsm/linuxgsm-configs \
 && chmod +x /home/linuxgsm/linuxgsm/lgsm/functions/* 

USER linuxgsm

# I'm not sure what `serverfiles/Saves` is created here for...
RUN mkdir logs serverfiles serverfiles/Saves

# HEALTHCHECK --start-period=30s CMD ./docker-health.sh

CMD ["bash", "./docker-runner.sh"]
