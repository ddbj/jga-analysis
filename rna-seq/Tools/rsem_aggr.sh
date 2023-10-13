#!/bin/bash

# ====STEP1=====
# 変数の読み込み rsem_isoforms:の配列
# .txtへ変換 rsem_isoforms
# 変数の読み込み rsem_genes:の配列
# .txtへ変換 rsem_genes:の配列
# 変数の読み込み prefix_rsem
# 作成した.txt、prefix_rsemをecho -> testのみの機能なのでのちに削除

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

# Echo results
echo "-i contents:"
cat $ISOFORMS_OUTFILE

echo "-g contents:"
cat $GENES_OUTFILE

echo "-p: $PREFIX"


# ======STEP2=======
# $なんちゃらをシェル内の変数に変更
# echo $(date +"[%b %d %H:%M:%S] Combining transcript-level output")
# python3 /TSCA/ccle_processing/RNA_pipeline/aggregate_rsem_results.py $1 TPM IsoPct expected_count $2
# echo $(date +"[%b %d %H:%M:%S] Combining gene-level output")
# python3 /TSCA/ccle_processing/RNA_pipeline/aggregate_rsem_results.py $3 TPM expected_count $2
