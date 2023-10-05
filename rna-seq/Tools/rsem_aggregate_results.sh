#!/bin/bash
git clone https://github.com/broadinstitute/ccle_processing.git
echo $(date +"[%b %d %H:%M:%S] Combining transcript-level output")
python3 ccle_processing/RNA_pipeline/aggregate_rsem_results.py $1 TPM IsoPct expected_count $2
echo $(date +"[%b %d %H:%M:%S] Combining gene-level output")
python3 ccle_processing/RNA_pipeline/aggregate_rsem_results.py $3 TPM expected_count $2

# git clone https://github.com/broadinstitute/ccle_processing.git
# echo $(date +"[%b %d %H:%M:%S] Combining transcript-level output")
# python3 ccle_processing/RNA_pipeline/aggregate_rsem_results.py ${write_lines(rsem_isoforms)} TPM IsoPct expected_count ${prefix}
# echo $(date +"[%b %d %H:%M:%S] Combining gene-level output")
# python3 ccle_processing/RNA_pipeline/aggregate_rsem_results.py ${write_lines(rsem_genes)} TPM expected_count ${prefix}