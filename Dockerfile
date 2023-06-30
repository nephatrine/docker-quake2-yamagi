FROM nephatrine/nxbuilder:alpine AS builder

RUN echo "====== INSTALL LIBRARIES ======" \
 && apk add --no-cache mesa-dev sdl2-dev

RUN git -C /root clone --single-branch --depth=1 https://github.com/yquake2/yquake2.git
RUN git -C /root clone --single-branch --depth=1 https://github.com/DirtBagXon/3zb2-zigflag.git
RUN git -C /root clone --single-branch --depth=1 https://github.com/packetflinger/lmctf.git
RUN git -C /root clone --single-branch --depth=1 https://github.com/packetflinger/openffa.git
RUN git -C /root clone --single-branch --depth=1 https://github.com/packetflinger/opentdm.git
RUN git -C /root clone --single-branch --depth=1 https://github.com/yquake2/ctf.git
RUN git -C /root clone --single-branch --depth=1 https://github.com/yquake2/rogue.git
RUN git -C /root clone --single-branch --depth=1 https://github.com/yquake2/xatrix.git
RUN git -C /root clone --single-branch --depth=1 https://github.com/yquake2/zaero.git
RUN git -C /root clone --single-branch --depth=1 https://github.com/yquake2/pakextract.git

RUN echo "====== COMPILE QUAKE II ======" \
 && cd /root/yquake2 \
 && make -j$(( $(getconf _NPROCESSORS_ONLN) / 2 + 1 )) server game \
 && cd /root/ctf \
 && make -j$(( $(getconf _NPROCESSORS_ONLN) / 2 + 1 ))
RUN echo "====== COMPILE EXPANSIONS ======" \
 && cd /root/xatrix \
 && make -j$(( $(getconf _NPROCESSORS_ONLN) / 2 + 1 )) \
 && cd /root/rogue \
 && make -j$(( $(getconf _NPROCESSORS_ONLN) / 2 + 1 )) \
 && cd /root/zaero \
 && make -j$(( $(getconf _NPROCESSORS_ONLN) / 2 + 1 ))
RUN echo "====== COMPILE TOOLS ======" \
 && cd /root/pakextract \
 && make -j$(( $(getconf _NPROCESSORS_ONLN) / 2 + 1 ))
RUN echo "====== COMPILE 3ZB2 ======" \
 && cd /root/3zb2-zigflag \
 && if [ ! "$(uname)" = "x86_64" ]; then sed -i "s~-msse2 -mfpmath=sse~~g" Makefile; fi \
 && make -j$(( $(getconf _NPROCESSORS_ONLN) / 2 + 1 )) \
 && mv 3zb2/pak10.pak 3zb2/pak6.pak
RUN echo "====== COMPILE LMCTF ======" \
 && cd /root/lmctf \
 && make -j$(( $(getconf _NPROCESSORS_ONLN) / 2 + 1 )) \
 && mv game*.so game.so
RUN echo "====== COMPILE OPENFFA ======" \
 && cd /root/openffa \
 && make -j$(( $(getconf _NPROCESSORS_ONLN) / 2 + 1 )) \
 && mv game*.so game.so
RUN echo "====== COMPILE OPENTDM ======" \
 && cd /root/opentdm \
 && sed -i "s~shell pkg-config libcurl --cflags~shell curl-config --cflags~g" Makefile \
 && sed -i "s~shell pkg-config libcurl --libs~shell curl-config --libs~g" Makefile \
 && sed -i "s~-DCURL_STATICLIB~~g" Makefile \
 && sed -i 's~deps/[^ ]*~$(CURL_LIBS)~g' Makefile \
 && make -j$(( $(getconf _NPROCESSORS_ONLN) / 2 + 1 )) \
 && mv game*.so game.so

FROM nephatrine/alpine-s6:latest AS dedicated
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== INSTALL PACKAGES ======" \
 && apk add --no-cache libcurl screen sdl2 \
 && mkdir -p /mnt/shared

COPY --from=builder /root/pakextract/pakextract /usr/local/bin/
COPY --from=builder /root/yquake2/release/ /opt/quake2/
COPY --from=builder /root/yquake2/stuff/yq2.cfg /opt/quake2-data/baseq2/
COPY --from=builder /root/yquake2/stuff/mapfixes/baseq2/ /opt/quake2-data/baseq2/maps/
COPY --from=builder /root/yquake2/stuff/mapfixes/juggernaut/ /opt/quake2-data/jugfull/maps/
COPY --from=builder /root/ctf/release/ /opt/quake2/ctf/
COPY --from=builder /root/xatrix/release/ /opt/quake2/xatrix/
COPY --from=builder /root/xatrix/stuff/mapfixes/ /opt/quake2-data/xatrix/maps/
COPY --from=builder /root/rogue/release/ /opt/quake2/rogue/
COPY --from=builder /root/rogue/stuff/mapfixes/ /opt/quake2-data/rogue/maps/
COPY --from=builder /root/zaero/release/ /opt/quake2/zaero/
COPY --from=builder /root/zaero/stuff/mapfixes/ /opt/quake2-data/zaero/maps/
COPY --from=builder /root/3zb2-zigflag/release/ /opt/quake2/3zb2/
COPY --from=builder /root/3zb2-zigflag/3zb2/ /opt/quake2-data/3zb2/
COPY --from=builder /root/openffa/game.so /opt/quake2/openffa/
COPY --from=builder /root/opentdm/game.so /opt/quake2/opentdm/
COPY --from=builder /root/lmctf/game.so /opt/quake2/lmctf/
COPY override /

RUN echo "====== PREP FOR Q2ADMIN ======" \
 && cp /opt/quake2/baseq2/game.so /opt/quake2/baseq2/game.real.so \
 && cp /opt/quake2/ctf/game.so /opt/quake2/ctf/game.real.so \
 && cp /opt/quake2/xatrix/game.so /opt/quake2/xatrix/game.real.so \
 && cp /opt/quake2/rogue/game.so /opt/quake2/rogue/game.real.so \
 && cp /opt/quake2/zaero/game.so /opt/quake2/zaero/game.real.so \
 && cp /opt/quake2/3zb2/game.so /opt/quake2/3zb2/game.real.so \
 && cp /opt/quake2/openffa/game.so /opt/quake2/openffa/game.real.so \
 && cp /opt/quake2/opentdm/game.so /opt/quake2/opentdm/game.real.so \
 && cp /opt/quake2/lmctf/game.so /opt/quake2/lmctf/game.real.so

EXPOSE 27910/udp

FROM nephatrine/nginx-ssl:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== INSTALL PACKAGES ======" \
 && apk add --no-cache libcurl screen sdl2

ENV QUAKE2_MIRROR=true

COPY --from=dedicated /usr/local/bin /usr/local/bin
COPY --from=dedicated /opt/quake2 /opt/quake2
COPY --from=dedicated /opt/quake2-data /opt/quake2-data
COPY override/etc /etc

EXPOSE 80/tcp 443/tcp 27910/udp
