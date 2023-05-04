[Git](https://code.nephatrine.net/NephNET/docker-quake2-yamagi/src/branch/master) |
[Docker](https://hub.docker.com/r/nephatrine/quake2-server/) |
[unRAID](https://code.nephatrine.net/nephatrine/unraid-containers)

# Quake II Server

This docker image contains a Quake II dedicated server.

- [Alpine Linux](https://alpinelinux.org/) w/ [S6 Overlay](https://github.com/just-containers/s6-overlay)
- [NGINX](https://www.nginx.com/) w/ [CertBot](https://certbot.eff.org/) (with ``nginx`` tags)
- [Yamagi Quake II](https://yamagi.org/quake2/)

The ``nginx`` tags will provide an HTTP(S) mirror of the game files for clients
that support HTTP downloads.

You can spin up a quick temporary test container like this:

~~~
docker run --rm -p 27910:27910 -it nephatrine/quake2-server:latest /bin/bash
~~~

## Docker Tags

- **nephatrine/quake2-server:latest**: Yamagi Quake II / Alpine Latest

## Configuration Variables

You can set these parameters using the syntax ``-e "VARNAME=VALUE"`` on your
``docker run`` command. Some of these may only be used during initial
configuration and further changes may need to be made in the generated
configuration files.

- ``GAME_START``: Startup Arguments (*"+exec server.cfg"*)
- ``PUID``: Mount Owner UID (*1000*)
- ``PGID``: Mount Owner GID (*100*)
- ``TZ``: System Timezone (*America/New_York*)

If using the ``nginx`` tags, you can use the additional configuration options
documented for the [nginx-ssl](https://code.nephatrine.net/nephatrine/docker-nginx-ssl)
container.

## Persistent Mounts

You can provide a persistent mountpoint using the ``-v /host/path:/container/path``
syntax. These mountpoints are intended to house important configuration files,
logs, and application state (e.g. databases) so they are not lost on image
update.

- ``/mnt/config``: Persistent Data.
- ``/mnt/shared``: Optional - Shared Game Data.

Do not share ``/mnt/config`` volumes between multiple containers as they may
interfere with the operation of one another.

The ``/mnt/shared`` volume, if mounted, should contain a ``data/quake2``
directory with the Quake II game data that should be used. This can be shared
between multiple Quake II servers.

You can perform some basic configuration of the container using the files and
directories listed below.

- ``/mnt/config/data/quake2/``: Game Data. [*]
- ``/mnt/config/data/quake2/baseq2/server.cfg``: Default Quake II Configuration. [*]
- ``/mnt/config/etc/crontabs/<user>``: User Crontabs. [*]
- ``/mnt/config/etc/logrotate.conf``: Logrotate Global Configuration.
- ``/mnt/config/etc/logrotate.d/``: Logrotate Additional Configuration.

**[*] Changes to some configuration files may require service restart to take
immediate effect.**

## Network Services

This container runs network services that are intended to be exposed outside
the container. You can map these to host ports using the ``-p HOST:CONTAINER``
or ``-p HOST:CONTAINER/PROTOCOL`` syntax.

- ``27910/tcp``: Quake II Server. This is the game server.
