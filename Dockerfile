FROM ubuntu:rolling
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

ENV DEBIAN_FRONTEND=noninteractive
RUN echo "====== INSTALL PACKAGES ======" \
 && apt-get update -q \
 && apt-get -y -qq install apt-utils \
 && apt-get -y -q -o Dpkg::Options::="--force-confnew" install \
   quake2-server yamagi-quake2-core \
   wget \
 && apt-get clean \
 && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

RUN echo "====== BUILD MODULES ======" \
 && rm -rf /usr/share/games/quake2/baseq2/* \
 && apt-get update -q \
 && apt-get -y -q -o Dpkg::Options::="--force-confnew" install cmake g++ git make \
 && cd /usr/src \
 && git clone https://github.com/yquake2/ctf.git && cd ctf \
 && mkdir build && cd build \
 && cmake -DCMAKE_BUILD_TYPE=Release .. && make \
 && mkdir -p /usr/lib/yamagi-quake2/ctf && cp Release/game.so /usr/lib/yamagi-quake2/ctf/ \
 && mkdir /usr/share/games/quake2/ctf \
 && cd /usr/src \
 && git clone https://github.com/yquake2/3zb2.git && cd 3zb2 \
 && grep -v g_turret.c CMakeLists.txt > CMakeLists2.txt && mv CMakeLists2.txt CMakeLists.txt \
 && mkdir build && cd build \
 && cmake -DCMAKE_BUILD_TYPE=Release .. && make \
 && mkdir /usr/lib/yamagi-quake2/3zb2 && cp Release/game.so /usr/lib/yamagi-quake2/3zb2/ \
 && mkdir /usr/share/games/quake2/3zb2 \
 && cd /usr/src \
 && git clone https://github.com/yquake2/xatrix.git && cd xatrix \
 && mkdir build && cd build \
 && cmake -DCMAKE_BUILD_TYPE=Release .. && make \
 && mkdir /usr/lib/yamagi-quake2/xatrix && cp Release/game.so /usr/lib/yamagi-quake2/xatrix/ \
 && mkdir /usr/share/games/quake2/xatrix \
 && cd /usr/src \
 && git clone https://github.com/yquake2/rogue.git && cd rogue \
 && mkdir build && cd build \
 && cmake -DCMAKE_BUILD_TYPE=Release .. && make \
 && mkdir /usr/lib/yamagi-quake2/rogue && cp Release/game.so /usr/lib/yamagi-quake2/rogue/ \
 && mkdir /usr/share/games/quake2/rogue \
 && cd /usr/src \
 && git clone https://github.com/yquake2/zaero.git && cd zaero \
 && mkdir build && cd build \
 && cmake -DCMAKE_BUILD_TYPE=Release .. && make \
 && mkdir /usr/lib/yamagi-quake2/zaero && cp Release/game.so /usr/lib/yamagi-quake2/zaero/ \
 && mkdir /usr/share/games/quake2/zaero \
 && apt-get -y -q purge cmake g++ git make \
 && apt-get -y -q autoremove \
 && cd /usr/src && rm -rf /tmp/* /usr/src/* /var/lib/apt/lists/* /var/tmp/*

USER quake2-server
EXPOSE 27910/udp
ENTRYPOINT ["/usr/share/games/quake2/quake2-server"]
CMD ["+exec", "server.cfg"]
