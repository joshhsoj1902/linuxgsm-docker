# linuxgsm-docker

[![CircleCI][circle-image]][circle-url]

Unoffical Dockerized version of the [Linux Game Server Manager][lgsm-home] project
## Usage

The simplest way to start a server is to use a docker-compose command that looks like this:

```shell
docker-compose -p css -f examples/docker-compose.css.yml  up
```

`-p` sets the "project" name, this isn't needed, but it'll help if you're running multiple servers.

`-f` sets the compose file you want to run.

## Examples

In the examples folder there are sample setups for many game servers. Each compose file has a status section that describes the current state of that server. If I know the server is in a working state it'll say it there. There are many popular games that I don't own so can't properly test, if you are able to confirm that a server is working please let me know and I'll update the status section.

There will also be links to find what config options exist for that server and some details on save files.

## Configuration

All configuration is done via environment variables. All servers will reference a config file in the main linuxGSM project. For css that file is [here](https://github.com/GameServerManagers/LinuxGSM/blob/master/lgsm/config-default/config-lgsm/cssserver/_default.cfg). All settings in those `_default.cfg` can be set by prepending `LGSM_` onto the name of the config, everything should be capitalized.

For example, if you wanted to set the css "gslt" value the environment variable it would look like:

```yaml
    environment:
      - LGSM_GAMESERVERNAME=cssserver
      - LGSM_UPDATEINSTALLSKIP=UPDATE
      - LGSM_PORT=27015
      - LGSM_GSLT=myValue
```

Some games also support a config file. The config files currently supported are found [here](https://github.com/joshhsoj1902/linuxgsm-docker/tree/master/config-game-template). The configs in that folder are templated so that the environment variables can be injected more easily. If the game you're looking to play needs a custom config file I will need to manually add it, If the config file is out of date I'll need to manually update it. If this happens please open an issue and I'll get around to it ASAP.

To set one of these configs you just need to use the same variable you see in the config file. For example, if you wanted to change the default max players allowed on a minecraft server, you can see the config for that [here](https://github.com/joshhsoj1902/linuxgsm-docker/blob/master/config-game-template/Minecraft/server.properties.tmpl#L20), the config in this case would be `LGSM_MAX_PLAYERS`, So to change that in the docker-compose file you would want to set it like this:

```yaml
    environment:
      ## Out of the box LGSM
      - LGSM_GAMESERVERNAME=mcserver
      - LGSM_UPDATEINSTALLSKIP=UPDATE
      - LGSM_PORT=25565
      - LGSM_MAX_PLAYERS=10
```

## Save files

Many gameservers save files. By default all the compose files create a volume called `[project]_serverfiles`. The files in the volume are preserved across container restarts, but if you were to accidentally delete that volume the files would be gone.

Another option is to change how the files are saved. In the compose file if you update the `volumes` section to look like this

```yaml
    volumes:
      - /local/path/where/you/want/to/save:/home/linuxgsm/linuxgsm/serverfiles
```

The "left" side of that can be updated to a local folder on your computer. The files that the server writes will now be saved there instead. Since the data is now stored outside of docker it's a little easier to manage and backup.



[circle-image]: https://circleci.com/gh/joshhsoj1902/linuxgsm-docker/tree/master.svg?style=svg
[circle-url]: https://circleci.com/gh/joshhsoj1902/linuxgsm-docker/tree/master
[lgsm-config]: https://github.com/GameServerManagers/LinuxGSM/tree/master/lgsm/config-default/config-lgsm
[lgsm-home]: https://github.com/GameServerManagers/LinuxGSM
