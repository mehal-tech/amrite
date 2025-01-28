# FROM ubuntu:22.04 as ubuntu22builder
# ARG REMOTE_ARCH
# RUN echo https://github.com/WasmEdge/WasmEdge/releases/download/0.14.1/WasmEdge-0.14.1-manylinux2014_${REMOTE_ARCH}.tar.xz
# ENV DEBIAN_FRONTEND=noninteractive
# ENV TZ=Etc/UTC
# RUN apt-get dist-upgrade
# RUN apt update --fix-missing 
# RUN apt-get install -y  apt-transport-https
# RUN apt-get install -y curl g++ make git gcc build-essential pkgconf libtool libsystemd-dev libprotobuf-c-dev libcap-dev libseccomp-dev libyajl-dev go-md2man libtool autoconf python3 automake xz-utils --fix-missing
# # Direct download of the generic package as the arm version isn't available
# RUN curl -L https://github.com/WasmEdge/WasmEdge/releases/download/0.14.1/WasmEdge-0.14.1-manylinux2014_${REMOTE_ARCH}.tar.xz | tar xJf - -C /usr/local --strip-components=1
# WORKDIR /
# RUN git clone --depth 1 -b 1.8 --recursive https://github.com/containers/crun.git
# WORKDIR /crun
# RUN ./autogen.sh
# RUN ./configure --with-wasmedge --enable-embedded-yajl
# RUN make
# RUN mv crun crun-wasmedge

FROM ubuntu:24.04 as ubuntu24builder
ARG REMOTE_ARCH
RUN echo https://github.com/WasmEdge/WasmEdge/releases/download/0.14.1/WasmEdge-0.14.1-manylinux2014_${REMOTE_ARCH}.tar.xz

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
RUN apt-get dist-upgrade
RUN apt update --fix-missing
RUN apt-get install -y  apt-transport-https
RUN apt-get install -y curl g++ make git gcc build-essential pkgconf libtool libsystemd-dev libprotobuf-c-dev libcap-dev libseccomp-dev libyajl-dev go-md2man libtool autoconf python3 automake xz-utils --fix-missing
# Direct download of the generic package as the arm version isn't available
RUN curl -L https://github.com/WasmEdge/WasmEdge/releases/download/0.14.1/WasmEdge-0.14.1-manylinux2014_${REMOTE_ARCH}.tar.xz | tar xJf - -C /usr/local --strip-components=1
WORKDIR /
RUN git clone --depth 1 -b 1.8 --recursive https://github.com/containers/crun.git
WORKDIR /crun
RUN ./autogen.sh
RUN ./configure --with-wasmedge --enable-embedded-yajl
RUN make
RUN mv crun crun-wasmedge

FROM fedora:41 as fedora41builder
ARG REMOTE_ARCH
RUN dnf install -y make python git gcc automake autoconf libcap-devel \
    systemd-devel yajl-devel libseccomp-devel pkg-config \
    go-md2man glibc-static python3-libmount libtool xz
RUN curl -L https://github.com/WasmEdge/WasmEdge/releases/download/0.14.1/WasmEdge-0.14.1-manylinux2014_${REMOTE_ARCH}.tar.xz | tar xJf - -C /usr/local --strip-components=1
WORKDIR /
RUN git clone --depth 1 -b 1.8 --recursive https://github.com/containers/crun.git
WORKDIR /crun
RUN ./autogen.sh
RUN ./configure --with-wasmedge --enable-embedded-yajl
RUN make
RUN mv crun crun-wasmedge

FROM scratch 

WORKDIR "/vendor/ubuntu_22_04"
COPY --from=ubuntu22builder /usr/local/lib64/libwasmedge.so.0 /crun/crun-wasmedge ./

WORKDIR "/vendor/ubuntu_24_04"
COPY --from=ubuntu24builder /usr/local/lib64/libwasmedge.so.0 /crun/crun-wasmedge ./

WORKDIR "/vendor/fedora_41"
COPY --from=fedora41builder /usr/local/lib64/libwasmedge.so.0 /crun/crun-wasmedge ./