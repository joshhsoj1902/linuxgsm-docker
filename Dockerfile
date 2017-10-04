FROM cyrale/linuxgsm

WORKDIR /home/steam/linuxgsm

USER steam

RUN git fetch --all \
 && git reset --hard origin/master

RUN git checkout tags/170710.1

RUN  mkdir ~/bin \
  && curl -sSLf -z ~/bin/gomplate -o ~/bin/gomplate https://github.com/hairyhenderson/gomplate/releases/download/v2.0.0/gomplate_linux-amd64-slim \
  && chmod 755 ~/bin/gomplate

USER root

RUN find /home/steam/linuxgsm -type f -name "*.sh" -exec chmod u+x {} \; \
 && find /home/steam/linuxgsm -type f -name "*.py" -exec chmod u+x {} \; \
 && chmod u+x /home/steam/linuxgsm/lgsm/functions/README.md

ADD common.cfg.tmpl ./lgsm/config-default/config-lgsm/

RUN chown -R steam:steam /home/steam/linuxgsm \
 && chmod -R 777 /home/steam/linuxgsm \
 && ls -ltr

ADD docker-runner.sh docker-health.sh ./

RUN chown steam:steam docker-runner.sh docker-health.sh \
 && chmod +x docker-runner.sh docker-health.sh

USER steam

HEALTHCHECK --start-period=45s CMD ./docker-health.sh

CMD ["bash", "./docker-runner.sh"]
