#!/bin/bash

echo $USE_BQSR

if ! $USE_BQSR; then
    cp $BAM $OUT_PREFIX.bam
    touch $OUT_PREFIX.recal_data.table
    exit 0
fi

/usr/bin/java \
    $GATK4_BASE_RECALIBRATOR_JAVA_OPTIONS \
    -jar /tools/gatk-4.1.0.0/gatk-package-4.1.0.0-local.jar \
    BaseRecalibrator \
    -R $REFERENCE \
    -I $BAM \
    --use-original-qualities $USE_ORIGINAL_QUALITIES \
    --known-sites $DBSNP \
    --known-sites $MILLS \
    --known-sites $KNOWN_INDELS \
    -O $OUT_PREFIX.recal_data.table

/usr/bin/java \
    $GATK4_APPLY_BQSR_JAVA_OPTIONS \
    -jar /tools/gatk-4.1.0.0/gatk-package-4.1.0.0-local.jar \
    ApplyBQSR \
    --add-output-sam-program-record \
    -R $REFERENCE \
    -I $BAM \
    --use-original-qualities $USE_ORIGINAL_QUALITIES \
    -bqsr $OUT_PREFIX.recal_data.table \
    $STATIC_QUANTIZED_QUALS_OPTIONS \
    -O $OUT_PREFIX.bam
