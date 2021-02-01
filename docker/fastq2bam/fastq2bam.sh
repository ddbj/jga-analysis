#!/bin/bash

READ_GROUP=@RG\\tID:${RG_ID}\\tPL:${RG_PL}\\tPU:${RG_PU}\\tLB:${RG_LB}\\tSM:${RG_SM}

/tools/bwa-0.7.15/bwa mem \
    -t $BWA_NUM_THREADS \
    -K $BWA_BASES_PER_BATCH \
    -T 0 \
    -Y \
    -R $READ_GROUP \
    $REFERENCE \
    $FASTQ1 $FASTQ2 \
| /usr/bin/java \
    $SORTSAM_JAVA_OPTIONS \
    -jar /tools/gatk-4.1.0.0/gatk-package-4.1.0.0-local.jar \
    SortSam \
    --MAX_RECORDS_IN_RAM=$SORTSAM_MAX_RECORDS_IN_RAM \
    -I=/dev/stdin \
    -O=$BAM \
    --SORT_ORDER=coordinate
