# GATK-JCBP-CWL
GATK Joint Calling Biggest PracticesワークフローのCWL
# CLI
## Reblock.cwl
### Usage
```
  cwltool --cachedir cash/Reblock \
    --outdir output/Reblock \
    --singularity GATK-JCBP-CWL/Tools/Reblock.cwl \
    --ref_fasta /path/to/Homo_sapiens_assembly38.fasta \
    --gvcf /path/to/NA18939.autosome.g.vcf.gz
```
