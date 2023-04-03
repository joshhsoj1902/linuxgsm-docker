FROM joshhsoj1902/linuxgsm-docker:base-latest

# RUN mkdir logs serverfiles

# This dir shouldn't be used anymore, use Saves instead
# RUN mkdir serverfiles/Saves

# serverfiles/Saves is meant to be a common place to put save files when a server supports putting the files somewhere.
# Creating this folder now works around https://github.com/docker/compose/issues/3270
# RUN mkdir Saves

# ARG OS=linux
# ARG ARCH=amd64

# HEALTHCHECK --start-period=60s --timeout=300s --interval=60s --retries=3 CMD curl -f http://localhost:28080/live || exit 1

ENV LGSM_GAMESERVERNAME=gmodserver
