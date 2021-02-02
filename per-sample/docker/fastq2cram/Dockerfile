FROM ubuntu:16.04
MAINTAINER Takeshi Fujino <fujino@edu.k.u-tokyo.ac.jp>

WORKDIR /tools

RUN apt-get update && \
    apt-get install -y \
    bzip2 \
    gcc \
    gfortran \
    g++ \
    libblas-dev \
    libbz2-dev \
    liblzma-dev \
    libncurses5-dev \
    make \
    openjdk-8-jre \
    software-properties-common \
    unzip \
    wget \
    zlib1g-dev

RUN apt-get -y clean && \
    apt-get -y autoremove && \
    apt-get -y autoclean

# bwa-0.7.15
RUN wget http://sourceforge.net/projects/bio-bwa/files/bwa-0.7.15.tar.bz2 && \
    tar xjf bwa-0.7.15.tar.bz2 && \
    rm -f bwa-0.7.15.tar.bz2 && \
    cd bwa-0.7.15 && \
    make

# samtools-1.9
RUN wget https://sourceforge.net/projects/samtools/files/samtools/1.9/samtools-1.9.tar.bz2 && \
    tar xjf samtools-1.9.tar.bz2 && \
    rm -f samtools-1.9.tar.bz2 && \
    cd samtools-1.9 && \
    make && \
    make install

# htslib-1.9
RUN wget https://github.com/samtools/htslib/releases/download/1.9/htslib-1.9.tar.bz2 && \
    tar jxvf htslib-1.9.tar.bz2 && \
    cd htslib-1.9 && \
    ./configure && \
    make && \
    make install

# gatk-4.1.0.0
RUN wget https://github.com/broadinstitute/gatk/releases/download/4.1.0.0/gatk-4.1.0.0.zip && \
    unzip gatk-4.1.0.0.zip && \
	rm -f gatk-4.1.0.0.zip

COPY fastq2bam.sh .

CMD ["/bin/bash"]
