# per-sample workflow

TODO: write about license if needed (GATK)

## Preparation for running workflows

### Server recommendations

- Memory >= 64GB
- Threads >= 16
- Disk space >= 100GB per sample

### Install software

- Install CWL execution engine on your Server
  - cwltool 3.1.20210816212154
    - execution on single machine
    - This is also needed for toil
  - toil git+https://github.com/DataBiosphere/toil.git@aa50bbfdef66bd9a861fb889325e476405fe25b6
    - execution via jobscheduler
  - galaxy-tool-util  21.9.2
    - This is needed for toil

`requirements.txt` is following

```text
git+https://github.com/DataBiosphere/toil.git@aa50bbfdef66bd9a861fb889325e476405fe25b6
cwltool==3.1.20210816212154
galaxy-tool-util==21.9.2
```


### Data required to run workflows

TODO: write FTP address

FILE list

### Small open data for testing

TODO: small samples on ftp site

## From FastQ file(s) to a BAM file

### Tools/fastqPE2bam.cwl

This workflow takes as input paired-end (PE) fastq files and outputs a BAM file.
PE fastq files are mapped onto a human reference genome using BWA MEM (version TODO: version), which outputs a SAM file.
Then, the SAM file is sorted and converted into BAM file using picard SortSam command (version TODO: version).

- Usage example
- Job file example
- Input parameters specified in job file
- Steps in this workflow
- Output files

### Tools/fastqSE2bam.cwl

This workflow takes as input a single-end (SE) fastq file and outputs a BAM file.
SE fastq file is mapped onto a human reference genome using BWA MEM (TODO: version ), which outputs a SAM file.
Then, the SAM file is sorted and converted into BAM file using picard SortSam command (TODO: version).

- Usage example
- Job file example
- Input parameters specified in job file
- Steps in this workflow
- Output files

## From BAM file(s) to a genomic VCF file

### TODO: Workflows/bams2gvcf.***

haplotype caller ?



### Workflows/per-sample.cwl

- Usage example

TODO: write cwltool sample

```console
cwltool --outdir output/ --singularity per-sample/Workflows/per-sample.cwl job-file.yaml
```

If temporary directory is specified(`/data/usr/temp`) and singularity does not mount it by default, use following.

```console
SINGULARITY_BIND=/data/usr/temp cwltool --outdir output/ --singularity per-sample/Workflows/per-sample.cwl job-file.yaml
```


- Job file example

Sample job file `job-file.yaml`

Replace

- TOPDIR is replaced with referece data top directory.
- PERSAMPLEDIR is replaced with temporary directory.
  - if you do not specified temporary directory, remove `-Djava.io.tmpdir=PERSAMPLEDIR`

```yaml
reference:
  class: File
  path: TOPDIR/Homo_sapiens_assembly38.fasta
  format: http://edamontology.org/format_1929
sortsam_max_records_in_ram: 5000000
sortsam_java_options: -XX:-UseContainerSupport -Xmx30g -Djava.io.tmpdir=PERSAMPLEDIR
gatk4_MarkDuplicates_java_option: -XX:-UseContainerSupport -Xmx32g -Xms32g -Djava.io.tmpdir=PERSAMPLEDIR
gatk4_BaseRecalibrator_java_options: -XX:-UseContainerSupport -Xmx4g -Xms4g -Djava.io.tmpdir=PERSAMPLEDIR
gatk4_ApplyBQSR_java_options: -XX:-UseContainerSupport -Xmx3g -Xms3g -Djava.io.tmpdir=PERSAMPLEDIR
gatk4_HaplotypeCaller_java_options: -XX:-UseContainerSupport -Xmx14g -Djava.io.tmpdir=PERSAMPLEDIR
fastq2bam_ram_min: 48000
fastq2bam_cores_min: 16
bams2cram_ram_min: 48000
bams2cram_cores_min: 6
haplotypecaller_ram_min: 48000
haplotypecaller_cores_min: 6
bwa_bases_per_batch: 10000000
use_bqsr: false
dbsnp:
  class: File
  path: TOPDIR/Homo_sapiens_assembly38.dbsnp138.vcf
  format: http://edamontology.org/format_3016
mills:
  class: File
  path: TOPDIR/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz
  format: http://edamontology.org/format_3016
known_indels:
  class: File
  path: TOPDIR/Homo_sapiens_assembly38.known_indels.vcf.gz
  format: http://edamontology.org/format_3016
haplotypecaller_autosome_PAR_interval_bed:
  class: File
  path: TOPDIR/autosome-PAR.bed
  format: http://edamontology.org/format_3584
haplotypecaller_autosome_PAR_interval_list:
  class: File
  path: TOPDIR/autosome-PAR.interval_list
haplotypecaller_chrX_nonPAR_interval_bed:
  class: File
  path: TOPDIR/chrX-nonPAR.bed
  format: http://edamontology.org/format_3584
haplotypecaller_chrX_nonPAR_interval_list:
  class: File
  path: TOPDIR/chrX-nonPAR.interval_list
haplotypecaller_chrY_nonPAR_interval_bed:
  class: File
  path: TOPDIR/chrY-nonPAR.bed
  format: http://edamontology.org/format_3584
haplotypecaller_chrY_nonPAR_interval_list:
  class: File
  path: TOPDIR/chrY-nonPAR.interval_list
sample_id: NA19023
runlist_pe:
  - run_id: ERR1347662
    platform_name: ILLUMINA
    fastq1:
      class: File
      path: TOPDIR/very-small/ERR1347662.small_1.fastq.gz
      format: http://edamontology.org/format_1930
    fastq2:
      class: File
      path: TOPDIR/very-small/ERR1347662.small_2.fastq.gz
      format: http://edamontology.org/format_1930
runlist_se: []
```

- Input parameters specified in job file

TODO: Input parameters specified in job file

- Steps in this workflow

TODO: tool name and version

- Output files

```
NA19023.autosome_PAR_ploidy_2.g.vcf.gz
NA19023.autosome_PAR_ploidy_2.g.vcf.gz.bcftools-stats
NA19023.autosome_PAR_ploidy_2.g.vcf.gz.bcftools-stats.log
NA19023.autosome_PAR_ploidy_2.g.vcf.gz.log
NA19023.autosome_PAR_ploidy_2.g.vcf.gz.tbi
NA19023.autosome_PAR_ploidy_2.g.vcf.gz.tbi.log
NA19023.autosome_PAR_ploidy_2.g.vcf.log
NA19023.bam.log
NA19023.chrX_nonPAR_ploidy_1.g.vcf.gz
NA19023.chrX_nonPAR_ploidy_1.g.vcf.gz.bcftools-stats
NA19023.chrX_nonPAR_ploidy_1.g.vcf.gz.bcftools-stats.log
NA19023.chrX_nonPAR_ploidy_1.g.vcf.gz.log
NA19023.chrX_nonPAR_ploidy_1.g.vcf.gz.tbi
NA19023.chrX_nonPAR_ploidy_1.g.vcf.gz.tbi.log
NA19023.chrX_nonPAR_ploidy_1.g.vcf.log
NA19023.chrX_nonPAR_ploidy_2.g.vcf.gz
NA19023.chrX_nonPAR_ploidy_2.g.vcf.gz.bcftools-stats
NA19023.chrX_nonPAR_ploidy_2.g.vcf.gz.bcftools-stats.log
NA19023.chrX_nonPAR_ploidy_2.g.vcf.gz.log
NA19023.chrX_nonPAR_ploidy_2.g.vcf.gz.tbi
NA19023.chrX_nonPAR_ploidy_2.g.vcf.gz.tbi.log
NA19023.chrX_nonPAR_ploidy_2.g.vcf.log
NA19023.chrY_nonPAR_ploidy_1.g.vcf.gz
NA19023.chrY_nonPAR_ploidy_1.g.vcf.gz.bcftools-stats
NA19023.chrY_nonPAR_ploidy_1.g.vcf.gz.bcftools-stats.log
NA19023.chrY_nonPAR_ploidy_1.g.vcf.gz.log
NA19023.chrY_nonPAR_ploidy_1.g.vcf.gz.tbi
NA19023.chrY_nonPAR_ploidy_1.g.vcf.gz.tbi.log
NA19023.chrY_nonPAR_ploidy_1.g.vcf.log
NA19023.cram
NA19023.cram.autosome_PAR_ploidy_2.wgs_metrics
NA19023.cram.autosome_PAR_ploidy_2.wgs_metrics.log
NA19023.cram.chrX_nonPAR_ploidy_1.wgs_metrics
NA19023.cram.chrX_nonPAR_ploidy_1.wgs_metrics.log
NA19023.cram.chrX_nonPAR_ploidy_2.wgs_metrics
NA19023.cram.chrX_nonPAR_ploidy_2.wgs_metrics.log
NA19023.cram.chrY_nonPAR_ploidy_1.wgs_metrics
NA19023.cram.chrY_nonPAR_ploidy_1.wgs_metrics.log
NA19023.cram.collect_base_dist_by_cycle
NA19023.cram.collect_base_dist_by_cycle.chart.pdf
NA19023.cram.collect_base_dist_by_cycle.chart.png
NA19023.cram.crai
NA19023.cram.crai.log
NA19023.cram.flagstat
NA19023.cram.idxstats
NA19023.cram.log
NA19023.log
NA19023.metrics.txt
```