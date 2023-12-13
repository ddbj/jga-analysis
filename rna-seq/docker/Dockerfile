# Base Image
 FROM --platform=linux/amd64 us-docker.pkg.dev/depmap-omics/public/ccle-rnaseq:latest

 # Install R Packages
 RUN git clone https://github.com/broadinstitute/ccle_processing.git

 # COPY shellscript
 COPY rsem_aggr.sh .