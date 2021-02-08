#!/bin/bash

ln -s $REFERENCE .
/opt/gridss/gridss.sh \
    $CRAM \
    -o $VCF \
    -a $ASSEMBLY \
    -r $REFERENCE \
    -t $NUM_THREADS \
    --picardoptions VALIDATION_STRINGENCY=LENIENT \
    --jvmheap $JVM_HEAP
