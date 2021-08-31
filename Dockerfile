FROM nephatrine/alpine-s6:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== COMPILE QUAKE II ======" \
 && apk add \
  screen sdl2 \
 && apk add --virtual .build-quake2 build-base \
  clang \
  curl-dev \
  git \
  linux-headers \
  openssl-dev \
  sdl2-dev \
 && git -C /usr/src clone --single-branch --depth=1 https://github.com/yquake2/yquake2.git && cd /usr/src/yquake2 \
 && make server game && mv release /opt/quake2 \
 && mkdir -p /opt/quake2-data/baseq2/maps && cp stuff/mapfixes/baseq2/*.ent /opt/quake2-data/baseq2/maps/ \
 && mkdir -p /opt/quake2-data/jugfull/maps && cp stuff/mapfixes/juggernaut/*.ent /opt/quake2-data/jugfull/maps/ \
 && mv stuff/yq2.cfg /opt/quake2-data/baseq2/ \
 && git -C /usr/src clone --single-branch --depth=1 https://github.com/yquake2/ctf.git && cd /usr/src/ctf \
 && make && mv release /opt/quake2/ctf \
 && git -C /usr/src clone --single-branch --depth=1 https://github.com/yquake2/xatrix.git && cd /usr/src/xatrix \
 && make && mv release /opt/quake2/xatrix \
 && mkdir -p /opt/quake2-data/xatrix/maps && cp stuff/mapfixes/*.ent /opt/quake2-data/xatrix/maps/ \
 && git -C /usr/src clone --single-branch --depth=1 https://github.com/yquake2/rogue.git && cd /usr/src/rogue \
 && make && mv release /opt/quake2/rogue \
 && mkdir -p /opt/quake2-data/rogue/maps && cp stuff/mapfixes/*.ent /opt/quake2-data/rogue/maps/ \
 && git -C /usr/src clone --single-branch --depth=1 https://github.com/yquake2/zaero.git && cd /usr/src/zaero \
 && make && mv release /opt/quake2/zaero \
 && mkdir -p /opt/quake2-data/zaero/maps && cp stuff/mapfixes/*.ent /opt/quake2-data/zaero/maps/ \
 && git -C /usr/src clone --single-branch --depth=1 https://github.com/yquake2/slightmechanicaldestruction.git && cd /usr/src/slightmechanicaldestruction \
 && make && mv release /opt/quake2/smd \
 && git -C /usr/src clone --single-branch --depth=1 https://github.com/DirtBagXon/3zb2-zigflag.git && cd /usr/src/3zb2-zigflag \
 && make && mv release /opt/quake2/3zb2 \
 && mv 3zb2/pak10.pak 3zb2/pak6.pak && mv 3zb2 /opt/quake2-data/ \
 && git -C /usr/src clone --single-branch --depth=1 https://github.com/yquake2/pakextract.git && cd /usr/src/pakextract \
 && make && mv pakextract /usr/local/bin/ \
 && git -C /usr/src clone --single-branch --depth=1 https://github.com/cee-studio/orca.git && cd /usr/src/orca \
 && make botx && make install \
 && git -C /usr/src clone --single-branch --depth=1 https://code.nephatrine.net/nephatrine/q2admin-nxmod.git && cd /usr/src/q2admin-nxmod \
 && make && mv release /opt/quake2-data/q2admin \
 && mv *.txt *.json /opt/quake2-data/q2admin/ \
 && cp /opt/quake2/baseq2/game.so /opt/quake2/baseq2/game.real.so \
 && cp /opt/quake2/3zb2/game.so /opt/quake2/3zb2/game.real.so \
 && cp /opt/quake2/ctf/game.so /opt/quake2/ctf/game.real.so \
 && cp /opt/quake2/xatrix/game.so /opt/quake2/xatrix/game.real.so \
 && cp /opt/quake2/rogue/game.so /opt/quake2/rogue/game.real.so \
 && cp /opt/quake2/zaero/game.so /opt/quake2/zaero/game.real.so \
 && cp /opt/quake2/smd/game.so /opt/quake2/smd/game.real.so \
 && mkdir -p /mnt/shared \
 && cd /usr/src && rm -rf /usr/src/* \
 && apk del --purge .build-quake2 && rm -rf /var/cache/apk/*

COPY override /
EXPOSE 27910/udp
