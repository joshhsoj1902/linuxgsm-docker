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
        iproute2 \
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
        wget \
        xvfb \
    # Cleanup
    && apt-get -y autoremove \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/*

COPY --from=joshhsoj1902/parse-env:1.0.3 /go/src/github.com/joshhsoj1902/parse-env/main /usr/bin/parse-env
COPY --from=hairyhenderson/gomplate:v3.1.0-alpine /bin/gomplate /usr/bin/gomplate

# Add the linuxgsm user
RUN adduser \
      --disabled-login \
      --disabled-password \
      --shell /bin/bash \
      --gecos "" \
      linuxgsm \
    && usermod -G tty linuxgsm \
    && chown -R linuxgsm:linuxgsm /home/linuxgsm

# Switch to the user linuxgsm
USER linuxgsm

# Install LinuxGSM
# RUN git clone "https://github.com/GameServerManagers/LinuxGSM.git" /home/linuxgsm/linuxgsm \
#  && git checkout tags/181124 \
#  && rm -rf /home/linuxgsm/linuxgsm/.git \

RUN git clone "https://github.com/joshhsoj1902/LinuxGSM.git" /home/linuxgsm/linuxgsm \
 && git checkout joshhsoj1902-changes-4-docker \
 && rm -rf /home/linuxgsm/linuxgsm/.git \
# Install GameConfigs
 && git clone "https://github.com/GameServerManagers/Game-Server-Configs.git" /home/linuxgsm/linuxgsm/lgsm/config-default/config-game/ \
 && rm -rf /home/linuxgsm/linuxgsm-config/.git

# ADD --chown=linuxgsm:linuxgsm src /home/linuxgsm/linuxgsm
# RUN git clone "https://github.com/GameServerManagers/Game-Server-Configs.git" /home/linuxgsm/linuxgsm/lgsm/config-default/config-game/ \
#  && rm -rf /home/linuxgsm/linuxgsm-config/.git

USER root 
 
RUN find /home/linuxgsm/linuxgsm -type f -name "*.sh" -exec chmod u+x {} \; \
 && find /home/linuxgsm/linuxgsm -type f -name "*.py" -exec chmod u+x {} \; \
 && chmod u+x /home/linuxgsm/linuxgsm/lgsm/functions/README.md

ADD --chown=linuxgsm:linuxgsm common.cfg.tmpl ./lgsm/config-default/config-lgsm/
ADD --chown=linuxgsm:linuxgsm docker-runner.sh docker-liveness.sh docker-readiness.sh ./
ADD --chown=linuxgsm:linuxgsm config-game-template/ /home/linuxgsm/linuxgsm/lgsm/config-default/config-game-template/

USER linuxgsm

RUN mkdir logs serverfiles 

# This dir shouldn't be used anymore, use Saves instead
RUN mkdir serverfiles/Saves

# serverfiles/Saves is meant to be a common place to put save files when a server supports putting the files somewhere.
# Creating this folder now works around https://github.com/docker/compose/issues/3270
RUN mkdir Saves


HEALTHCHECK --start-period=60s --timeout=300s --interval=60s --retries=3 CMD ./docker-liveness.sh

ENTRYPOINT ["bash", "./docker-runner.sh"]
