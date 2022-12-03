# JGA analysis per-sample workflow

This workflow takes FASTQ files as input, aligns them to the reference genome (GRCh38), and performs variant call per sample. The alignment results (CRAM), variant call results per sample (gVCF), and quality control metrics (CRAM-level and gVCF-level metrics) used in later steps are output.

This workflow consists of the following steps:
- Alignment (FASTQ to SAM): bwa mem (version 0.7.15)
- SAM to BAM: GATK SortSam (version 4.1.0.0)
- MarkDuplicates: GATK MarkDuplicates (version 4.1.0.0)
- BQSR (optional): GATK BaseRecalibrator (version 4.1.0.0), GATK ApplyBQSR (version 4.1.0.0)
- BAM to CRAM: samtools view -C (version 1.9), samtools index (version 1.9)
- Calculate cram-level metrics: samtools idxstats (version 1.9), samtools flagstat (version 1.9), GATK CollectBaseDistributionByCycle (version 4.2.0.0), GATK CollectWgsMetrics (version 4.2.0.0)
- Variant call: GATK HaplotypeCaller -ERC GVCF (version 4.1.0.0), bgzip (version 1.9), tabix (version 1.9)
- Calculate gVCF-level metrics: bcftools stats (version 1.9)


## Recommendations
- Memory >= 64GB
- Threads >= 16
- Disk space >= 100GB per sample

## Set up execution environments

Install CWL execution engine on your Server
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

## Data required to run workflows
Reference genome data and index files can be downloaded from DDBJ FTP site (ftp://ftp.ddbj.nig.ac.jp/ddbjshare-pg/jga-analysis) or [DDBJ HTTPS site](https://ddbj.nig.ac.jp/public/ddbjshare-pg/jga-analysis))

## Execute the per-sample workflow

### Usage

```console
cwltool --outdir output/ --singularity per-sample/Workflows/per-sample.cwl job-file.yaml
```

If temporary directory is specified(`/data/usr/temp`) and singularity does not mount it by default, use following.

```console
SINGULARITY_BIND=/data/usr/temp cwltool --outdir output/ --singularity per-sample/Workflows/per-sample.cwl job-file.yaml
```

### Job file

Let a sample job file be `job-file.yaml`. 

- Please specify TOPDIR to be a referece data top directory.
- Please specify PERSAMPLEDIR to be a temporary directory (if you do not specified temporary directory, remove `-Djava.io.tmpdir=PERSAMPLEDIR`)

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

