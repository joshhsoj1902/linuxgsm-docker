# Operator
FROM golang:1.15.0 AS builder
RUN mkdir -p /src
ADD Makefile /

COPY src/ /src/
WORKDIR /

RUN make build-monitor

FROM ubuntu:18.04

WORKDIR /home/linuxgsm/linuxgsm

# Stop apt-get asking to get Dialog frontend
ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

ENV LGSM_CONSOLE_STDOUT=true
ENV LGSM_SCRIPT_STDOUT=true
ENV LGSM_ALERT_STDOUT=true
ENV LGSM_GAME_STDOUT=true

# Install dependencies and clean
# RUN echo steam steam/question select "I AGREE" | debconf-set-selections && \
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
    apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository multiverse && \
    dpkg --add-architecture i386 && \
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
        lib32z1 \
        libc6 \
        libstdc++6 \
        libstdc++6:i386 \
        lib32stdc++6 \
        libtinfo5:i386 \
        libsdl2-2.0-0:i386 \
        libgconf-2-4 \
        mailutils \
        net-tools \
        netcat \
        postfix \
        python \
        # steamcmd \
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

# Install Gamedig https://docs.linuxgsm.com/requirements/gamedig
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - \
    && apt-get update && apt-get install -y nodejs \
    && npm install -g gamedig \
    # Cleanup
    && apt-get -y autoremove \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/*

COPY --from=joshhsoj1902/parse-env:1.0.3 /go/src/github.com/joshhsoj1902/parse-env/main /usr/bin/parse-env
COPY --from=hairyhenderson/gomplate:v3.6.0-alpine /bin/gomplate /usr/bin/gomplate

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
# ADD --chown=linuxgsm:linuxgsm LinuxGSM/ /home/linuxgsm/linuxgsm

# Install LinuxGSM
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
ADD --chown=linuxgsm:linuxgsm docker-runner.sh ./
# ADD --chown=linuxgsm:linuxgsm lgsm/ /home/linuxgsm/linuxgsm/lgsm/
ADD --chown=linuxgsm:linuxgsm config-game-template/ /home/linuxgsm/linuxgsm/lgsm/config-default/config-game-template/

# This file isn't always created when running in docker. Ideally we shouldn't need it.
RUN touch /.dockerenv

USER linuxgsm

COPY --chown=linuxgsm:linuxgsm --from=builder /monitor monitor

RUN mkdir logs serverfiles 

# This dir shouldn't be used anymore, use Saves instead
RUN mkdir serverfiles/Saves

# serverfiles/Saves is meant to be a common place to put save files when a server supports putting the files somewhere.
# Creating this folder now works around https://github.com/docker/compose/issues/3270
RUN mkdir Saves

ARG BUILD_DATE
ARG VCS_REF
ARG OS=linux
ARG ARCH=amd64

LABEL org.opencontainers.image.created=$BUILD_DATE \
      org.opencontainers.image.revision=$VCS_REF \
      org.opencontainers.image.source="https://github.com/joshhsoj1902/linuxgsm-docker"

HEALTHCHECK --start-period=60s --timeout=300s --interval=60s --retries=3 CMD curl -f http://localhost:28080/live || exit 1

ENTRYPOINT ["bash", "./docker-runner.sh"]
