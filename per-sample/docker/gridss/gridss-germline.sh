#!/bin/bash

ln -s $REFERENCE .
ln -s $REFERENCE.amb .
ln -s $REFERENCE.ann .
ln -s $REFERENCE.bwt .
ln -s $REFERENCE.pac .
ln -s $REFERENCE.sa .
ln -s $REFERENCE.alt .
ln -s $REFERENCE.fai .

/opt/gridss/gridss.sh \
    $CRAM \
    -o $VCF \
    -a $ASSEMBLY \
    -r $(basename $REFERENCE) \
    -t $NUM_THREADS \
    --picardoptions VALIDATION_STRINGENCY=LENIENT \
    --jvmheap $JVM_HEAP
