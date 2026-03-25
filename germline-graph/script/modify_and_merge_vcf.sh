#!/bin/bash

set -xe
set -o pipefail

MAX_ALLELE_LENGTH=100000
SCRIPT_DIR=$(dirname "$0")
OUT_PREFIX=$1
shift

TEMP=$(mktemp -d)
for VCF_GZ in "$@"
do
    BASENAME=$(basename "$VCF_GZ" .vcf.gz)
    bcftools view -H "$VCF_GZ" | cut -f 1-4 | sort -k 1,1 -k 2,2n -k 3,3 > "$TEMP"/"$BASENAME".pos.tsv
done
sort -k 1,1 -k 2,2n -k 3,3 -m -u "$TEMP"/*.pos.tsv > "$OUT_PREFIX".pos.tsv
sort -k 3,3 -s "$OUT_PREFIX.pos.tsv" > "$OUT_PREFIX.pos.id_sort.tsv"
awk 'BEGIN {FS=OFS="\t"} {print $1,$2,$4,$3}' "$OUT_PREFIX.pos.id_sort.tsv" | uniq -f 3 -d > "$OUT_PREFIX.pos.dup.tsv"

MERGE_TARGETS=()
for VCF_GZ in "$@"
do
    BASENAME=$(basename "$VCF_GZ" .vcf.gz)
    bcftools view "$VCF_GZ" | bundle exec ruby "$SCRIPT_DIR"/modify_vcf_pos.rb "$OUT_PREFIX".pos.dup.tsv > "$TEMP"/"$BASENAME".mod.vcf
    vcfbub -l 0 -a "$MAX_ALLELE_LENGTH" --input "$TEMP"/"$BASENAME".mod.vcf | bcftools sort -O z -W=tbi -o "$TEMP"/"$BASENAME".mod.bub.vcf.gz
    MERGE_TARGETS+=("$TEMP"/"$BASENAME".mod.bub.vcf.gz)
done
bcftools merge -m all -O z -W=tbi -o "$OUT_PREFIX".vcf.gz "${MERGE_TARGETS[@]}"
rm -rf "$TEMP"
