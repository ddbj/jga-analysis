#!/bin/bash

# Initialize variables
ISOFORMS=()
GENES=()
PREFIX=""
ISOFORMS_OUTFILE="isoforms_output.txt"
GENES_OUTFILE="genes_output.txt"

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -i)
            shift
            while [[ "$#" -gt 0 && "$1" != -* ]]; do
                ISOFORMS+=("$1")
                shift
            done
            ;;
        -g)
            shift
            while [[ "$#" -gt 0 && "$1" != -* ]]; do
                GENES+=("$1")
                shift
            done
            ;;
        -p)
            shift
            PREFIX="$1"
            shift
            ;;
        *)
            echo "Unknown parameter: $1"
            exit 1
            ;;
    esac
done

# Write ISOFORMS to file
> $ISOFORMS_OUTFILE
for iso in "${ISOFORMS[@]}"; do
    echo "$iso" >> $ISOFORMS_OUTFILE
done

# Write GENES to file
> $GENES_OUTFILE
for gene in "${GENES[@]}"; do
    echo "$gene" >> $GENES_OUTFILE
done

# col merge
echo $(date +"[%b %d %H:%M:%S] Combining transcript-level output")
python3 /TSCA/ccle_processing/RNA_pipeline/aggregate_rsem_results.py $ISOFORMS_OUTFILE TPM IsoPct expected_count $PREFIX
echo $(date +"[%b %d %H:%M:%S] Combining gene-level output")
python3 /TSCA/ccle_processing/RNA_pipeline/aggregate_rsem_results.py $GENES_OUTFILE TPM expected_count $PREFIX
