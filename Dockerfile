FROM pdr.nephatrine.net/nephatrine/alpine-builder:latest AS builder

RUN echo "====== INSTALL LIBRARIES ======" \
 && apk add --no-cache curl-dev openssl-dev sdl2-dev

RUN git -C /usr/src clone --single-branch --depth=1 https://github.com/yquake2/yquake2.git
RUN git -C /usr/src clone --single-branch --depth=1 https://github.com/yquake2/ctf.git
RUN git -C /usr/src clone --single-branch --depth=1 https://github.com/yquake2/xatrix.git
RUN git -C /usr/src clone --single-branch --depth=1 https://github.com/yquake2/rogue.git
RUN git -C /usr/src clone --single-branch --depth=1 https://github.com/yquake2/zaero.git
RUN git -C /usr/src clone --single-branch --depth=1 https://github.com/yquake2/slightmechanicaldestruction.git
RUN git -C /usr/src clone --single-branch --depth=1 https://github.com/DirtBagXon/3zb2-zigflag.git
RUN git -C /usr/src clone --single-branch --depth=1 https://github.com/yquake2/pakextract.git

RUN echo "====== COMPILE QUAKE II ======" \
 && cd /usr/src/yquake2 \
 && make server game \
 && cd /usr/src/ctf \
 && make
RUN echo "====== COMPILE EXPANSIONS ======" \
 && cd /usr/src/xatrix \
 && make \
 && cd /usr/src/rogue \
 && make \
 && cd /usr/src/zaero \
 && make
RUN echo "====== COMPILE MODS ======" \
 && cd /usr/src/slightmechanicaldestruction \
 && make \
 && cd /usr/src/3zb2-zigflag \
 && make \
 && mv 3zb2/pak10.pak 3zb2/pak6.pak
RUN echo "====== COMPILE TOOLS ======" \
 && cd /usr/src/pakextract \
 && make

FROM pdr.nephatrine.net/nephatrine/alpine-s6:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== INSTALL PACKAGES ======" \
 && apk add --no-cache libcurl screen sdl2 \
 && mkdir -p /mnt/shared

COPY --from=builder /usr/src/yquake2/release/ /opt/quake2/
COPY --from=builder /usr/src/ctf/release/ /opt/quake2/ctf/
COPY --from=builder /usr/src/xatrix/release/ /opt/quake2/xatrix/
COPY --from=builder /usr/src/rogue/release/ /opt/quake2/rogue/
COPY --from=builder /usr/src/zaero/release/ /opt/quake2/zaero/
COPY --from=builder /usr/src/slightmechanicaldestruction/release/ /opt/quake2/smd/
COPY --from=builder /usr/src/3zb2-zigflag/release/ /opt/quake2/3zb2/
COPY --from=builder /usr/src/yquake2/stuff/yq2.cfg /opt/quake2-data/baseq2/
COPY --from=builder /usr/src/yquake2/stuff/mapfixes/baseq2/ /opt/quake2-data/baseq2/maps/
COPY --from=builder /usr/src/yquake2/stuff/mapfixes/juggernaut/ /opt/quake2-data/jugfull/maps/
COPY --from=builder /usr/src/xatrix/stuff/mapfixes/ /opt/quake2-data/xatrix/maps/
COPY --from=builder /usr/src/rogue/stuff/mapfixes/ /opt/quake2-data/rogue/maps/
COPY --from=builder /usr/src/zaero/stuff/mapfixes/ /opt/quake2-data/zaero/maps/
COPY --from=builder /usr/src/3zb2-zigflag/3zb2/ /opt/quake2-data/3zb2/
COPY --from=builder /usr/src/pakextract/pakextract /usr/local/bin/
COPY override /

RUN echo "====== PREP FOR Q2ADMIN ======" \
 && cp /opt/quake2/baseq2/game.so /opt/quake2/baseq2/game.real.so \
 && cp /opt/quake2/3zb2/game.so /opt/quake2/3zb2/game.real.so \
 && cp /opt/quake2/ctf/game.so /opt/quake2/ctf/game.real.so \
 && cp /opt/quake2/xatrix/game.so /opt/quake2/xatrix/game.real.so \
 && cp /opt/quake2/rogue/game.so /opt/quake2/rogue/game.real.so \
 && cp /opt/quake2/zaero/game.so /opt/quake2/zaero/game.real.so \
 && cp /opt/quake2/smd/game.so /opt/quake2/smd/game.real.so

EXPOSE 27910/udp
