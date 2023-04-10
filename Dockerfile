FROM nephatrine/nxbuilder:alpine AS builder

RUN echo "====== INSTALL LIBRARIES ======" \
 && apk add --no-cache mesa-dev sdl2-dev

RUN git -C /root clone --single-branch --depth=1 https://github.com/yquake2/yquake2.git
RUN git -C /root clone --single-branch --depth=1 https://github.com/yquake2/ctf.git
RUN git -C /root clone --single-branch --depth=1 https://github.com/yquake2/xatrix.git
RUN git -C /root clone --single-branch --depth=1 https://github.com/yquake2/rogue.git
RUN git -C /root clone --single-branch --depth=1 https://github.com/yquake2/zaero.git
RUN git -C /root clone --single-branch --depth=1 https://github.com/yquake2/slightmechanicaldestruction.git
RUN git -C /root clone --single-branch --depth=1 https://github.com/DirtBagXon/3zb2-zigflag.git
RUN git -C /root clone --single-branch --depth=1 https://github.com/yquake2/pakextract.git
RUN git -C /root clone --single-branch --depth=1 https://github.com/nephatrine/q25_game.git

RUN echo "====== COMPILE QUAKE II ======" \
 && cd /root/yquake2 \
 && make server game \
 && cd /root/ctf \
 && make
RUN echo "====== COMPILE EXPANSIONS ======" \
 && cd /root/xatrix \
 && make \
 && cd /root/rogue \
 && make \
 && cd /root/zaero \
 && make
RUN echo "====== COMPILE MODS ======" \
 && cd /root/slightmechanicaldestruction \
 && make \
 && cd /root/3zb2-zigflag \
 && make \
 && mv 3zb2/pak10.pak 3zb2/pak6.pak \
 && cd /root/q25_game \
 && mkdir release && mkdir build && cd build \
 && cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DNO_EXTRACTFUNCS=ON -DNEPHATRINE_TWEAKS=ON .. \
 && ninja && cp gamex86_64.so ../release/game.so
RUN echo "====== COMPILE TOOLS ======" \
 && cd /root/pakextract \
 && make

FROM nephatrine/alpine-s6:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== INSTALL PACKAGES ======" \
 && apk add --no-cache libcurl screen sdl2 \
 && mkdir -p /mnt/shared

COPY --from=builder /root/yquake2/release/ /opt/quake2/
COPY --from=builder /root/ctf/release/ /opt/quake2/ctf/
COPY --from=builder /root/xatrix/release/ /opt/quake2/xatrix/
COPY --from=builder /root/rogue/release/ /opt/quake2/rogue/
COPY --from=builder /root/zaero/release/ /opt/quake2/zaero/
COPY --from=builder /root/slightmechanicaldestruction/release/ /opt/quake2/smd/
COPY --from=builder /root/3zb2-zigflag/release/ /opt/quake2/3zb2/
COPY --from=builder /root/q25/release/ /opt/quake2/q25/
COPY --from=builder /root/yquake2/stuff/yq2.cfg /opt/quake2-data/baseq2/
COPY --from=builder /root/yquake2/stuff/mapfixes/baseq2/ /opt/quake2-data/baseq2/maps/
COPY --from=builder /root/yquake2/stuff/mapfixes/juggernaut/ /opt/quake2-data/jugfull/maps/
COPY --from=builder /root/xatrix/stuff/mapfixes/ /opt/quake2-data/xatrix/maps/
COPY --from=builder /root/rogue/stuff/mapfixes/ /opt/quake2-data/rogue/maps/
COPY --from=builder /root/zaero/stuff/mapfixes/ /opt/quake2-data/zaero/maps/
COPY --from=builder /root/3zb2-zigflag/3zb2/ /opt/quake2-data/3zb2/
COPY --from=builder /root/pakextract/pakextract /usr/local/bin/
COPY override /

RUN echo "====== PREP FOR Q2ADMIN ======" \
 && cp /opt/quake2/baseq2/game.so /opt/quake2/baseq2/game.real.so \
 && cp /opt/quake2/3zb2/game.so /opt/quake2/3zb2/game.real.so \
 && cp /opt/quake2/ctf/game.so /opt/quake2/ctf/game.real.so \
 && cp /opt/quake2/xatrix/game.so /opt/quake2/xatrix/game.real.so \
 && cp /opt/quake2/rogue/game.so /opt/quake2/rogue/game.real.so \
 && cp /opt/quake2/zaero/game.so /opt/quake2/zaero/game.real.so \
 && cp /opt/quake2/smd/game.so /opt/quake2/smd/game.real.so \
 && cp /opt/quake2/q25/game.so /opt/quake2/q25/game.real.so

EXPOSE 27910/udp
