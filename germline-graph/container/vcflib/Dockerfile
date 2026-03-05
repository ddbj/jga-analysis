FROM ubuntu:26.04
LABEL maintainer="fujino@edu.k.u-tokyo.ac.jp"
ENV VCFLIB_COMMIT=8b5d4c8143ed486669f9f0f124cae0882b747fb8
ENV LD_LIBRARY_PATH=/usr/local/lib
RUN apt-get update && \
    apt-get install -y \
      libbz2-dev \
      zlib1g-dev \
      liblzma-dev \
      libhts-dev \
      libwfa2-dev \
      git \
      gcc \
      g++ \
      make \
      cmake \
      pkg-config \
      python3 \
      pybind11-dev
WORKDIR /work
RUN git clone --recursive https://github.com/vcflib/vcflib.git
WORKDIR /work/vcflib
RUN git switch --detach $VCFLIB_COMMIT
WORKDIR /work/vcflib/build
RUN cmake -DCMAKE_BUILD_TYPE=Release -DZIG=OFF ..
RUN cmake --build .
RUN cmake --install .
