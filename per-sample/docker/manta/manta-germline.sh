#!/bin/bash

python /manta/bin/configManta.py \
  --bam $BAM \
  --referenceFasta $REFERENCE \
  $CONFIG_MANTA_OPTION && \
python MantaWorkflow/runWorkflow.py $WORKFLOW_OPTION
