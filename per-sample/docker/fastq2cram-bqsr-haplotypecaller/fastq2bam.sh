#!/bin/bash

READ_GROUP=@RG\\tID:${RG_ID}\\tPL:${RG_PL}\\tPU:${RG_PU}\\tLB:${RG_LB}\\tSM:${RG_SM}

# if FASTQ1 - FASTQ2 or both are bz2. convert to gz on /tmp
FASTQ1FILE=${FASTQ1}
FASTQ2FILE=${FASTQ2}
FASTQ1CONVERT=0
FASTQ2CONVERT=0

if [ ! -z ${FASTQ1} ]; then
  if [[ ${FASTQ1} != "" ]]; then
    FASTQ1EXT=$(echo ${FASTQ1} | sed 's/^.*\.\([^\.]*\)$/\1/')
    FASTQ1BASENAME=$(basename ${FASTQ1})
    if [[ "${FASTQ1EXT}" == "bz2" ]]; then
      FASTQ1FILE=/tmp/$FASTQ1BASENAME.gz
      bzip2 -d -c ${FASTQ1} | gzip > ${FASTQ1FILE}
      FASTQ1CONVERT=1
    fi
  fi
fi


if [ ! -z ${FASTQ2} ]; then
  if [[ ${FASTQ2} != "" ]]; then
    FASTQ2EXT=$(echo ${FASTQ2} | sed 's/^.*\.\([^\.]*\)$/\1/')
    FASTQ2BASENAME=$(basename ${FASTQ2})
    if [[ "${FASTQ2EXT}" == "bz2" ]]; then
      FASTQ2FILE=/tmp/$FASTQ2BASENAME.gz
      bzip2 -d -c ${FASTQ2} | gzip > ${FASTQ2FILE}
      FASTQ2CONVERT=1
    fi
  fi
fi

# 
/tools/bwa-0.7.15/bwa mem \
    -t $BWA_NUM_THREADS \
    -K $BWA_BASES_PER_BATCH \
    -T 0 \
    -Y \
    -R $READ_GROUP \
    $REFERENCE \
    $FASTQ1FILE $FASTQ2FILE \
| /usr/bin/java \
    $SORTSAM_JAVA_OPTIONS \
    -jar /tools/gatk-4.1.0.0/gatk-package-4.1.0.0-local.jar \
    SortSam \
    --MAX_RECORDS_IN_RAM=$SORTSAM_MAX_RECORDS_IN_RAM \
    -I=/dev/stdin \
    -O=$BAM \
    --SORT_ORDER=coordinate

if ${FASTQ1CONVERT} -eq 1; then
  rm ${FASTQ1FILE}
fi
if ${FASTQ2CONVERT} -eq 1; then
  rm ${FASTQ2FILE}
fi
