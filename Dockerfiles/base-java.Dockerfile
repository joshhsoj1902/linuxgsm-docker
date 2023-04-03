FROM joshhsoj1902/linuxgsm-docker:base-latest


# https://adoptium.net/releases.html?variant=openjdk16&jvmVariant=hotspot
RUN mkdir -p /bin/java && \
    curl -sL 'https://github.com/adoptium/temurin16-binaries/releases/download/jdk-16.0.2%2B7/OpenJDK16U-jdk_x64_linux_hotspot_16.0.2_7.tar.gz' | tar zxvf - -C /bin/java

ENV PATH="/bin/java/jdk-16.0.2+7/bin:${PATH}"

# Install dependencies and clean
# RUN echo steam steam/question select "I AGREE" | debconf-set-selections && \
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
    apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository multiverse && \
    dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y \
    # This default-jre isn't used, The above jdk is used instead. linuxGSM still looks for this to be installed
    default-jre \
    # Cleanup
    && apt-get -y autoremove \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/*
