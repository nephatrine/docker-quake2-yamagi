<!--
SPDX-FileCopyrightText: 2020 - 2025 Daniel Wolf <nephatrine@gmail.com>

SPDX-License-Identifier: ISC
-->

[Git](https://code.nephatrine.net/NephNET/docker-quake2-yamagi/src/branch/master) |
[Docker](https://hub.docker.com/r/nephatrine/quake2-server/) |
[unRAID](https://code.nephatrine.net/NephNET/unraid-containers)

# Yamagi Quake II Dedicated Server

This docker container manages the Yamagi Quake II dedicated server.

The `yamagi` tag points to version `8.50` and this is the only image
actively being updated. There are tags for older versions, but these may no
longer be using the latest Alpine version and packages.

## Docker-Compose

These are example docker-compose files for various setups.

### Single Server

This is just a simple Quake II server.

```yaml
services:
  quake2-server:
    image: nephatrine/quake2-server:yamagi
    container_name: quake2-server
    environment:
      TZ: America/New_York
      PUID: 1000
      PGID: 1000
    ports:
      - "27910:27910/udp"
    volumes:
      - /mnt/containers/quake2-server:/mnt/config
```

### Single Server w/ HTTP Mirror

This container is set up to create an HTTP mirror of the game contents so that
players joining can get better download speeds on engines that support it. You
can easily add an NGINX container and map a separate volume that is shared
between the game server and NGINX. Then you can just put that volume in
`QUAKE2_MIRROR` and the `${QUAKE2_MIRROR}/www/quake2` directory will reflect
the installed game data on the server.

**NB:** You will need to manually configure NGINX's config to share
`/mnt/config/www/quake2`.

```yaml
services:
  quake2-server:
    image: nephatrine/quake2-server:yamagi
    container_name: quake2-server
    environment:
      TZ: America/New_York
      PUID: 1000
      PGID: 1000
      QUAKE2_MIRROR: /mnt/mirror
    ports:
      - "27910:27910/udp"
    volumes:
      - /mnt/containers/quake2-server:/mnt/config
      - /mnt/containers/quake2-http:/mnt/mirror
  quake2-http:
    image: nephatrine/nginx-ssl:latest
    container_name: quake2-http
    environment:
      TZ: America/New_York
      PUID: 1000
      PGID: 1000
      ADMINIP: 127.0.0.1
      TRUSTSN: 192.168.0.0/16
      DNSADDR: "8.8.8.8 8.8.4.4"
    ports:
      - "80:8080/tcp"
    volumes:
      - /mnt/containers/quake2-http:/mnt/config
```

### Multiple Servers

This is an example where you want to run two servers on the same host. In such
cases, it is possible to have them use a shared game data volume. You just map
a separate volume that is shared by both and put that volume in
`QUAKE2_INSTALL` on one and `QUAKE2_DATA` on the other. Make sure that the
first container starts before the other so that the installation is all set up
for it and you should be good to go.

When hosting multiple servers, you *can* use a port setting of
`27911:27910/udp` instead of specifying a different internal listening port in
`GAME_START`, but the port is used for both the port being listened to by the
server as well as what they advertise to the master server. So if you want your
servers to show up properly in the master servers, you'll want to specify the
port each should run on and map those separate ports on both sides.

```yaml
services:
  quake2-server-1:
    image: nephatrine/quake2-server:yamagi
    container_name: quake2-server-1
    environment:
      TZ: America/New_York
      PUID: 1000
      PGID: 1000
      QUAKE2_INSTALL: /mnt/shared
	  GAME_START: "+set port 27910 +exec server.cfg"
    ports:
      - "27910:27910/udp"
    volumes:
      - /mnt/containers/quake2-server-1:/mnt/config
      - /mnt/containers/quake2-data:/mnt/shared
  quake2-server-2:
    image: nephatrine/quake2-server:yamagi
    container_name: quake2-server-2
    environment:
      TZ: America/New_York
      PUID: 1000
      PGID: 1000
      QUAKE2_DATA: /mnt/shared
	  GAME_START: "+set port 27911 +game ctf +exec server.cfg"
    ports:
      - "27911:27911/udp"
    depends_on:
      - quake2-server-1
    volumes:
      - /mnt/containers/quake2-server-2:/mnt/config
      - /mnt/containers/quake2-data:/mnt/shared
```

## Server Configuration

These are the configuration and data files you will likely need to be aware of
and potentially customize.

- `${QUAKE2_DATA}/data/quake2/*`
- `${QUAKE2_DATA}/data/quake2/baseq2/server.cfg`

By customizing the `GAME_START` variable, you can run in a different game
directory or exec a different config file, of course.

Modifications to some of these may require a service restart to pull in the
changes made.
