[Git](https://code.nephatrine.net/nephatrine/docker-quake2) |
[Docker](https://hub.docker.com/r/nephatrine/quake2-server/) |
[unRAID](https://code.nephatrine.net/nephatrine/unraid-containers)

[![Build Status](https://ci.nephatrine.net/api/badges/nephatrine/docker-quake2/status.svg?ref=refs/heads/master)](https://ci.nephatrine.net/nephatrine/docker-quake2)

# Docker Registry

This docker image contains a Docker Registry server to self-host your own
docker registry.

**YOU WILL NEED TO USE A SEPARATE REVERSE PROXY SERVER TO SECURE THIS SERVICE.
SEE THE [DOCUMENTATION](https://docs.docker.com/registry/recipes/nginx/) FOR
MORE DETAILS ON HOW TO CONFIGURE SUCH A PROXY.**

- [Docker Registry](https://docs.docker.com/registry/)

You can spin up a quick temporary test container like this:

~~~
docker run --rm -p 27910:27910 -it nephatrine/quake2-server:latest /bin/bash
~~~

## Persistent Mounts

You can provide a persistent mountpoint using the ``-v /host/path:/container/path``
syntax. These mountpoints are intended to house important configuration files,
logs, and application state (e.g. databases) so they are not lost on image
update.

- ``/usr/share/games/quake2/baseq2``: Quake II Game Data.
- ``/usr/share/games/quake2/ctf``: CTF Game Data.
- ``/usr/share/games/quake2/xatrix``: The Reckoning Game Data.
- ``/usr/share/games/quake2/rogue``: Ground Zero Game Data.
- ``/usr/share/games/quake2/zaero``: Zaero Game Data.
- ``/usr/share/games/quake2/3zb2``: 3rd Zigock Bot Game Data.

There is no game data included in the image - not even the shareware demo.
Please populate this yourself with a legal copy of Quake II.

On startup, the game will execute the ``server.cfg`` found in the ``baseq2``
folder and so you can configure settings there.

## Network Services

This container runs network services that are intended to be exposed outside
the container. You can map these to host ports using the ``-p HOST:CONTAINER``
or ``-p HOST:CONTAINER/PROTOCOL`` syntax.

- ``27910/tcp``: Quake II Server. This is the game server.
