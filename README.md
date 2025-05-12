<!--
SPDX-FileCopyrightText: 2020-2025 Daniel Wolf <nephatrine@gmail.com>
SPDX-License-Identifier: ISC
-->

# Quake II Dedicated Server

[![NephCode](https://img.shields.io/static/v1?label=Git&message=NephCode&color=teal)](https://code.nephatrine.net/NephNET/docker-quake2-yamagi)
[![GitHub](https://img.shields.io/static/v1?label=Git&message=GitHub&color=teal)](https://github.com/nephatrine/docker-quake2-yamagi)
[![Registry](https://img.shields.io/static/v1?label=OCI&message=NephCode&color=blue)](https://code.nephatrine.net/NephNET/-/packages/container/quake2-yamagi/latest)
[![DockerHub](https://img.shields.io/static/v1?label=OCI&message=DockerHub&color=blue)](https://hub.docker.com/repository/docker/nephatrine/quake2-yamagi/general)
[![unRAID](https://img.shields.io/static/v1?label=unRAID&message=template&color=orange)](https://code.nephatrine.net/NephNET/unraid-containers)

This is an Alpine-based container hosting a Yamagi Quake II dedicated game
server.

## Supported Tags

- `quake2-yamagi:8.50`: Yamagi Quake II 8.50

## Software

- [Alpine Linux](https://alpinelinux.org/)
- [Skarnet S6](https://skarnet.org/software/s6/)
- [s6-overlay](https://github.com/just-containers/s6-overlay)
- [Yamagi Quake II](https://www.yamagi.org/quake2/)

## Configuration

These are the configuration and data files you will likely need to be aware of
and potentially customize. `QUAKE2_DATA`, if unspecified, will default to
`/mnt/config/data/quake2`.

- `${QUAKE2_DATA}/baseq2/server.cfg`
- `${QUAKE2_DATA}/*`

Modifications to some of these may require a service restart to pull in the
changes made.

### Container Variables

- `TZ`: Time Zone (i.e. `America/New_York`)
- `PUID`: Mounted File Owner User ID
- `PGID`: Mounted File Owner Group ID
- `QUAKE2_DATA`: Use Quake II Here (i.e. `/mnt/config/data/quake2`)
- `QUAKE2_INSTALL`: Install Quake II Here (i.e. `/mnt/config/data/quake2`)
- `QUAKE2_MIRROR`: Create HTTP Mirror Here (i.e. `/mnt/mirror/www/quake2`)
- `GAME_START`: Extra Game Arguments (i.e. `+exec server.cfg`)

## Testing

### docker-compose

#### Simple Server

This is just a simple Quake II server.

```yaml
services:
  quake2-yamagi:
    image: nephatrine/quake2-yamagi:latest
    container_name: quake2-yamagi
    environment:
      TZ: America/New_York
      PUID: 1000
      PGID: 1000
    ports:
      - "27910:27910/udp"
    volumes:
      - /mnt/containers/quake2-yamagi:/mnt/config
```

#### Server w/ HTTP Mirror

This setup uses a simple NGINX container to serve an HTTP mirror of the maps and
other game files so that modern Quake II clients can download missing files more
easily.

```yaml
services:
  quake2-yamagi:
    image: nephatrine/quake2-yamagi:latest
    container_name: quake2-yamagi
    environment:
      TZ: America/New_York
      PUID: 1000
      PGID: 1000
      QUAKE2_MIRROR: /mnt/mirror/www/default
    ports:
      - "27910:27910/udp"
    volumes:
      - /mnt/containers/quake2-yamagi:/mnt/config
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

#### Multiple Servers

In some cases you may want to run multiple Quake II servers on a host that all
share the same data directory to avoid file duplication. In this case, you can
set up one of the containers to install the Quake II data to and then point the
other containers to the first's data directory.

```yaml
services:
  quake2-yamagi-1:
    image: nephatrine/quake2-yamagi:latest
    container_name: quake2-yamagi-1
    environment:
      TZ: America/New_York
      PUID: 1000
      PGID: 1000
      QUAKE2_INSTALL: /mnt/shared/data/quake2
      GAME_START: "+set port 27910 +exec server.cfg"
    ports:
      - "27910:27910/udp"
    volumes:
      - /mnt/containers/quake2-yamagi-1:/mnt/config
      - /mnt/containers/quake2-data:/mnt/shared
  quake2-yamagi-2:
    image: nephatrine/quake2-yamagi:latest
    container_name: quake2-yamagi-2
    environment:
      TZ: America/New_York
      PUID: 1000
      PGID: 1000
      QUAKE2_DATA: /mnt/shared/data/quake2
      GAME_START: "+set port 27911 +game ctf +exec server.cfg"
    ports:
      - "27911:27911/udp"
    depends_on:
      - quake2-yamagi-1
    volumes:
      - /mnt/containers/quake2-yamagi-2:/mnt/config
      - /mnt/containers/quake2-data:/mnt/shared
```

We specify the `+set port 27911` argument for the secondary server to change the
actual internal port rather than just setting the composed ports as
`27911:27910/udp` because the internally set port is also the port advertised on
master servers so needs to match the external port if you plan on showing up
properly.

### docker run

```bash
docker run --rm -ti code.nephatrine.net/nephnet/quake2-yamagi:latest /bin/bash
```
