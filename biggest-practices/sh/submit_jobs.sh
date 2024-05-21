#!/bin/bash

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 Reblock.sh sample_name_map.txt ref_fasta_path"
  exit 1
fi

reblock_script="$1"
sample_file="$2"
ref_fasta="$3"

current_dir=$(pwd)

while IFS=$'\t' read -r sample_name gvcf_path; do
  sbatch --job-name="$sample_name" "$reblock_script" "$sample_name" "$gvcf_path" "$ref_fasta" "$current_dir"
done < "$sample_file"
