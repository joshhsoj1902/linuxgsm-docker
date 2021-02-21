# Examples

These examples show some basic configurations for running various servers in docker.

Each compose file has a status section that describes the current state of the server. If I know the server is in a working state it'll say it there. 

## Usage

The most simple way to start a server is to run a command that looks like this:

```shell
docker-compose -p css -f examples/docker-compose.css.yml  up
```

`-p` sets the "project" name, this isn't needed, but it'll help if you're running multiple servers.

`-f` sets the compose file you want to run.

## Save files

Many gameservers save files. By default all the compose files create a volume called `[project]_serverfiles`. The files in the volume are preserved across container restarts, but if you were to accidently delete that volume the files would be gone.

Another option is to change how the files are saved. In the compose file if you update the `volumes` section to look like this

```yaml
    volumes:
      - /local/path/where/you/want/to/save:/home/linuxgsm/linuxgsm/serverfiles
```

The "left" side of that can be updated to a local folder on your computer. The files that the server write will now tbe saved there instead. Since the data is now stored outside of docker it's a little easier to manage and backup.
