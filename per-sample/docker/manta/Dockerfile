FROM ubuntu:18.04
LABEL maintainer="fujino@edu.k.u-tokyo.ac.jp"

WORKDIR /tools

RUN apt-get update && \
    apt-get install -y \
    bzip2 \
    cmake \
    gcc \
    g++ \
    libboost-dev \
    make \
    python \
    wget \
    zlib1g-dev

RUN wget https://github.com/Illumina/manta/releases/download/v1.6.0/manta-1.6.0.release_src.tar.bz2 && \
    tar -xjf manta-1.6.0.release_src.tar.bz2 && \
    mkdir build && \
    cd build && \
    ../manta-1.6.0.release_src/configure --jobs=4 --prefix=/manta && \
    make -j4 install

COPY manta-germline.sh .

CMD ["/bin/bash"]
