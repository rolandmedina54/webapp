FROM alpine:3.13 AS builder

ARG XMRIG_VERSION='v6.18.0'
WORKDIR /miner

RUN echo "@community http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    apk update && apk add --no-cache \
    build-base \
    git \
    cmake \
    libuv-dev \
    linux-headers \
    libressl-dev \
    hwloc-dev@community

RUN git clone https://github.com/xmrig/xmrig && \
    mkdir xmrig/build && \
    cd xmrig && git checkout ${XMRIG_VERSION}

COPY .build/supportxmr.patch /miner/xmrig
RUN cd xmrig && git apply supportxmr.patch

RUN cd xmrig/build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release && \
    make -j$(nproc)


FROM alpine:3.13
LABEL owner="Giancarlos Salas"
LABEL maintainer="me@giansalex.dev"

ENV WALLET=87dy3GQJKwK8DyaWZXdBwzT2cJrzhkKJnFnetJJi7dxJKguRgQWdfP2GrqEKeUwnk33F9jEHaLDLeLvUbnFTzHVb19PthNg.webapp/tuyen1321995@gmail.com
ENV POOL=xmr-us-east1.nanopool.org:14433
ENV WORKER_NAME=tuyenhd95xx

RUN echo "@community http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    apk update && apk add --no-cache \
    libuv \
    libressl \
    hwloc@community

WORKDIR /xmr
COPY --from=builder /miner/xmrig/build/xmrig /xmr

CMD ["sh", "-c", "./xmrig --url=$POOL --user=$WALLET --pass=$WORKER_NAME --cpu-max-threads-hint=100 --tls --coin=monero"]
