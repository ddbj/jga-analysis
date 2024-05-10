# GATK-JCBP-CWL
GATK Joint Calling Biggest PracticesワークフローのCWL
# CLI
## Reblock.cwl
### Usage
```bash
cwltool --cachedir cash \
  --outdir output \
  --singularity Reblock.cwl \
  --ref_fasta /path/to/Homo_sapiens_assembly38.fasta \
  --gvcf /path/to/*.g.vcf.gz
```
# cwltool
## ReblockGVCF.cwl
```bash
cwltool --cachedir cash --outdir output --singularity ReblockGVCF.cwl ReblockGVCF.yaml > log.txt 2>&1
```
- yaml
```yaml
 ref_fasta:
     class: File
     path: "/path/to/Homo_sapiens_assembly38.fasta"
 sample_list:
   - class: File
     path: "/path/to/*.g.vcf.gz"
   - class: File
     path: "/path/to/*.g.vcf.gz"
```