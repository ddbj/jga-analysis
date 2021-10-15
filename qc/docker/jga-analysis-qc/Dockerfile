FROM ruby:3.0.1
LABEL maintainer="fujino@edu.k.u-tokyo.ac.jp"

WORKDIR /work

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
    r-base r-cran-ggplot2 r-cran-readr

RUN git clone https://github.com/biosciencedbc/jga-analysis-qc.git
WORKDIR jga-analysis-qc
RUN git submodule update --init
RUN bundle config set without development
RUN bundle install
RUN rake install

CMD ["/bin/bash"]
