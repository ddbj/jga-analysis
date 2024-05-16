# GATK-JCBP-CWL
Execution of the GATK Joint Calling Best Practices workflow using CWL
# Reblock
## 1 sample・CLI 
```bash
cwltool --cachedir cash \
  --outdir output \
  --singularity Reblock.cwl \
  --ref_fasta /path/to/Homo_sapiens_assembly38.fasta \
  --gvcf /path/to/*.g.vcf.gz
```
## multi sample・ShellScript
### Usage
```bash
# ./submit_jobs.sh Reblock.sh sample_name_map.txt ref-file.fasta
./jga-analysis/biggest-practices/sh/submit_jobs.sh \
  jga-analysis/biggest-practices/sh/Reblock.sh \
  /path/to/sample_name_map.txt \
  /path/to/Homo_sapiens_assembly38.fasta
```
### sample_name_map.txt
- This file lists sample names and their corresponding gVCF file paths in tab-separated format. Each line consists of a "sample name" and its "file path" pair.
```bash
sampleA	/path/to/sampleA.g.vcf.gz
sampleB	/path/to/sampleB.g.vcf.gz
sampleC	/path/to/sampleC.g.vcf.gz
```
### secondary files
- Place the .fai and .dict files in the same directory as ref-file.fasta.
- Place the .tbi files in the same directory as the gVCF files.