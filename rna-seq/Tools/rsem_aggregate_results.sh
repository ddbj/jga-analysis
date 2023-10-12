#!/bin/bash
# echo $(date +"[%b %d %H:%M:%S] Combining transcript-level output")
# python3 /TSCA/ccle_processing/RNA_pipeline/aggregate_rsem_results.py $2 TPM IsoPct expected_count $3
# echo $(date +"[%b %d %H:%M:%S] Combining gene-level output")
# python3 /TSCA/ccle_processing/RNA_pipeline/aggregate_rsem_results.py $4 TPM expected_count $3
echo $(date +"[%b %d %H:%M:%S] Combining transcript-level output")
python3 /TSCA/ccle_processing/RNA_pipeline/aggregate_rsem_results.py $1 TPM IsoPct expected_count $2
echo $(date +"[%b %d %H:%M:%S] Combining gene-level output")
python3 /TSCA/ccle_processing/RNA_pipeline/aggregate_rsem_results.py $3 TPM expected_count $2