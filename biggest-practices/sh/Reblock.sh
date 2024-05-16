#!/bin/bash
#SBATCH --mem=32GB
#SBATCH --cpus-per-task=4
#SBATCH --output=log/%x_%j.txt

sample_name=$1
gvcf_path=$2
ref_fasta=$3
exec_dir=$4

# change directory (working dir)
cd "$exec_dir"

# create output dir
mkdir -p output/Reblock/$sample_name

# exec cwltool
cwltool --cachedir cash/Reblock \
--outdir output/Reblock/$sample_name \
--singularity \
jga-analysis/biggest-practices/Tools/Reblock.cwl \
--ref_fasta $ref_fasta \
--gvcf $gvcf_path
