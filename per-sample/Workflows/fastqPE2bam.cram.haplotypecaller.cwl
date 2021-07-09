#!/usr/bin/env cwl-runner

class: Workflow
id: fastqPE2bamworkflow
label: fastqPE2bamworkflow
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

requirements:
  SubworkflowFeatureRequirement: {}
  ScatterFeatureRequirement: {}
  StepInputExpressionRequirement: {}
  ResourceRequirement:
    outdirMin: 40960
    ramMin: 48000
    tmpdirMin: 65536
    coresMin: 16

inputs:
  reference:
    type: File
    format: edam:format_1929
    doc: FastA file for reference genome
    secondaryFiles:
      - .amb
      - .ann
      - .bwt
      - .pac
      - .sa
      - .alt
  bwa_num_threads:
    type: int
    doc: number of cpu cores to be used
    default: 1
  bwa_bases_per_batch:
    type: int
    doc: bases in each batch
    default: 10000000
  sortsam_java_options:
    type: string
    default: -XX:-UseContainerSupport -Xmx30g
  sortsam_max_records_in_ram:
    type: int
    default: 5000000
  runlist_pe:
    type:
      type: array
      items:
        - type: record
          fields:
            RG_ID:
              type: string
              doc: Read group identifier (ID) in RG line
            RG_PL:
              type: string
              doc: Platform/technology used to produce the read (PL) in RG line
            RG_PU:
              type: string
              doc: Platform Unit (PU) in RG line
            RG_LB:
              type: string
              doc: DNA preparation library identifier (LB) in RG line
            RG_SM:
              type: string
              doc: Sample (SM) identifier in RG line
            fastq1:
              type: File
              format: edam:format_1930
              doc: FastQ file from next-generation sequencers
            fastq2:
              type: File
              format: edam:format_1930
              doc: FastQ file from next-generation sequencers
            outprefix:
              type: string
  # bams2cram
  bams2cram_reference:
    type: File
    format: edam:format_1929
    doc: FastA file for reference genome
    secondaryFiles:
      - .fai
      - ^.dict

  bams2cram_outprefix:
    type: string
  use_bqsr:
    type: boolean
  use_original_qualities:
    type: string
    doc: true or false
    default: "false"
  dbsnp:
    type: File
    format: edam:format_3016
    secondaryFiles:
      - .idx
    doc: Homo_sapiens_assembly38.dbsnp138.vcf
  mills:
    type: File
    format: edam:format_3016
    secondaryFiles:
      - .tbi
    doc: Mills_and_1000G_gold_standard.indels.hg38.vcf.gz
  known_indels:
    type: File
    format: edam:format_3016
    secondaryFiles:
      - .tbi
    doc: Homo_sapiens_assembly38.known_indels.vcf.gz
  gatk4_MarkDuplicates_java_options:
    type: string?
  gatk4_BaseRecalibrator_java_options:
    type: string?
  gatk4_ApplyBQSR_java_options:
    type: string?
  static_quantized_quals:
    type:
      type: array
      items: int
    default: [10, 20, 30]
    doc: Use static quantized quality scores to a given number of levels (with -bqsr)
  samtools_num_threads:
    type: int
    default: 1
  # haplotypecaller common
  haplotypecaller_reference:
    type: File
    format: edam:format_1929
    doc: FastA file for reference genome
    secondaryFiles:
      - .fai
      - ^.dict
  sample_name:
    type: string
  gatk4_HaplotypeCaller_java_options:
    type: string?
  gatk4_HaplotypeCaller_num_threads:
    type: int
    default: 1
  bgzip_num_threads:
    type: int
    default: 1
  # haplotypecaller interval=autosome-PAR, ploidy=2
  haplotypecaller_autosome_PAR_ploidy_2_ploidy:
    type: int
    default: 2
  haplotypecaller_autosome_PAR_ploidy_2_interval_name:
    type: string
    default: autosome-PAR-ploidy-2
  haplotypecaller_autosome_PAR_ploidy_2_interval_bed:
    type: File
    format: edam:format_3584
  # haplotypecaller interval=chrX-nonPAR, ploidy=2
  haplotypecaller_chrX_nonPAR_ploidy_2_ploidy:
    type: int
    default: 2
  haplotypecaller_chrX_nonPAR_ploidy_2_interval_name:
    type: string
    default: chrX-nonPAR-ploidy-2
  haplotypecaller_chrX_nonPAR_ploidy_2_interval_bed:
    type: File
    format: edam:format_3584
  # haplotypecaller interval=chrX-nonPAR, ploidy=1
  haplotypecaller_chrX_nonPAR_ploidy_1_ploidy:
    type: int
    default: 1
  haplotypecaller_chrX_nonPAR_ploidy_1_interval_name:
    type: string
    default: chrX-nonPAR-ploidy-1
  haplotypecaller_chrX_nonPAR_ploidy_1_interval_bed:
    type: File
    format: edam:format_3584
  # haplotypecaller interval=chrY-nonPAR, ploidy=1
  haplotypecaller_chrY_nonPAR_ploidy_1_ploidy:
    type: int
    default: 1
  haplotypecaller_chrY_nonPAR_ploidy_1_interval_name:
    type: string
    default: chrY-nonPAR-ploidy-1
  haplotypecaller_chrY_nonPAR_ploidy_1_interval_bed:
    type: File
    format: edam:format_3584


steps:
  fastqPE2bam:
    run: ./fastqPE2bam-workflow.cwl
    in:
      reference: reference
      bwa_num_threads: bwa_num_threads
      bwa_bases_per_batch: bwa_bases_per_batch
      sortsam_java_options: sortsam_java_options
      sortsam_max_records_in_ram: sortsam_max_records_in_ram
      runlist_pe: runlist_pe
      RG_ID:
        valueFrom: $(inputs.runlist_pe.RG_ID)
      RG_LB:
        valueFrom: $(inputs.runlist_pe.RG_LB)
      RG_PL:
        valueFrom: $(inputs.runlist_pe.RG_PL)
      RG_PU:
        valueFrom: $(inputs.runlist_pe.RG_PU)
      RG_SM:
        valueFrom: $(inputs.runlist_pe.RG_SM)
      fastq1:
        valueFrom: $(inputs.runlist_pe.fastq1)
      fastq2:
        valueFrom: $(inputs.runlist_pe.fastq2)
      outprefix:
        valueFrom: $(inputs.runlist_pe.outprefix)
    scatter:
      - runlist_pe
    scatterMethod: dotproduct
    out:
      - bam
      - log
  bams2cram:
    run: ./bams2cram.cwl
    in:
      reference: bams2cram_reference
      bams: fastqPE2bam/bam
      use_bqsr: use_bqsr
      use_original_qualities: use_original_qualities
      dbsnp: dbsnp
      mills: mills
      known_indels: known_indels
      outprefix: bams2cram_outprefix
      gatk4_MarkDuplicates_java_options: gatk4_MarkDuplicates_java_options
      gatk4_BaseRecalibrator_java_options: gatk4_BaseRecalibrator_java_options
      gatk4_ApplyBQSR_java_options: gatk4_ApplyBQSR_java_options
      static_quantized_quals: static_quantized_quals
      samtools_num_threads: samtools_num_threads
    out:
      - markdup_metrics
      - markdup_log
      - cram
      - cram_log
      - crai_log
      - bqsr_log
      - samtools_idxstats_idxstats
      - samtools_flagstat_flagstat
      - picard-CollectBaseDistributionByCycle-collect_base_dist_by_cycle
      - picard-CollectBaseDistributionByCycle-chart-pdf
      - picard-CollectBaseDistributionByCycle-chart-png
  haplotypecaller_autosome_PAR_ploidy_2:
    run: ./haplotypecaller.cwl
    in:
      reference: haplotypecaller_reference
      cram: bams2cram/cram
      sample_name: sample_name
      interval_name: haplotypecaller_autosome_PAR_ploidy_2_interval_name
      interval_bed: haplotypecaller_autosome_PAR_ploidy_2_interval_bed
      gatk4_HaplotypeCaller_java_options: gatk4_HaplotypeCaller_java_options
      gatk4_HaplotypeCaller_num_threads: gatk4_HaplotypeCaller_num_threads
      ploidy: haplotypecaller_autosome_PAR_ploidy_2_ploidy
      bgzip_num_threads: bgzip_num_threads
    out:
      - vcf_gz
      - haplotypecaller_log
      - bgzip_log
      - tabix_log
      - bcftools_stats
      - bcftools_stats_log
  haplotypecaller_chrX_nonPAR_ploidy_2:
    run: ./haplotypecaller.cwl
    in:
      reference: haplotypecaller_reference
      cram: bams2cram/cram
      sample_name: sample_name
      interval_name: haplotypecaller_chrX_nonPAR_ploidy_2_interval_name
      interval_bed: haplotypecaller_chrX_nonPAR_ploidy_2_interval_bed
      gatk4_HaplotypeCaller_java_options: gatk4_HaplotypeCaller_java_options
      gatk4_HaplotypeCaller_num_threads: gatk4_HaplotypeCaller_num_threads
      ploidy: haplotypecaller_chrX_nonPAR_ploidy_2_ploidy
      bgzip_num_threads: bgzip_num_threads
    out:
      - vcf_gz
      - haplotypecaller_log
      - bgzip_log
      - tabix_log
      - bcftools_stats
      - bcftools_stats_log
  haplotypecaller_chrX_nonPAR_ploidy_1:
    run: ./haplotypecaller.cwl
    in:
      reference: haplotypecaller_reference
      cram: bams2cram/cram
      sample_name: sample_name
      interval_name: haplotypecaller_chrX_nonPAR_ploidy_1_interval_name
      interval_bed: haplotypecaller_chrX_nonPAR_ploidy_1_interval_bed
      gatk4_HaplotypeCaller_java_options: gatk4_HaplotypeCaller_java_options
      gatk4_HaplotypeCaller_num_threads: gatk4_HaplotypeCaller_num_threads
      ploidy: haplotypecaller_chrX_nonPAR_ploidy_1_ploidy
      bgzip_num_threads: bgzip_num_threads
    out:
      - vcf_gz
      - haplotypecaller_log
      - bgzip_log
      - tabix_log
      - bcftools_stats
      - bcftools_stats_log
  haplotypecaller_chrY_nonPAR_ploidy_1:
    run: ./haplotypecaller.cwl
    in:
      reference: haplotypecaller_reference
      cram: bams2cram/cram
      sample_name: sample_name
      interval_name: haplotypecaller_chrY_nonPAR_ploidy_1_interval_name
      interval_bed: haplotypecaller_chrY_nonPAR_ploidy_1_interval_bed
      gatk4_HaplotypeCaller_java_options: gatk4_HaplotypeCaller_java_options
      gatk4_HaplotypeCaller_num_threads: gatk4_HaplotypeCaller_num_threads
      ploidy: haplotypecaller_chrY_nonPAR_ploidy_1_ploidy
      bgzip_num_threads: bgzip_num_threads
    out:
      - vcf_gz
      - haplotypecaller_log
      - bgzip_log
      - tabix_log
      - bcftools_stats
      - bcftools_stats_log


outputs:
  # fastqPE2bam
  bam:
    type: File[]
    outputSource: fastqPE2bam/bam
  log:
    type: File[]
    outputSource: fastqPE2bam/log
  # bams2cram
  markdup_metrics:
    type: File
    outputSource: bams2cram/markdup_metrics
  markdup_log:
    type: File
    outputSource: bams2cram/markdup_log
  cram:
    type: File
    outputSource: bams2cram/cram
  cram_log:
    type: File
    outputSource: bams2cram/cram_log
  crai_log:
    type: File
    outputSource: bams2cram/crai_log
  bqsr_log:
    type: File
    outputSource: bams2cram/bqsr_log
  samtools_idxstats_idxstats:
    type: File
    outputSource: bams2cram/samtools_idxstats_idxstats
  samtools_flagstat_flagstat:
    type: File
    outputSource: bams2cram/samtools_flagstat_flagstat
  picard-CollectBaseDistributionByCycle-collect_base_dist_by_cycle:
    type: File
    outputSource: bams2cram/picard-CollectBaseDistributionByCycle-collect_base_dist_by_cycle
  picard-CollectBaseDistributionByCycle-chart-pdf:
    type: File
    outputSource: bams2cram/picard-CollectBaseDistributionByCycle-chart-pdf
  picard-CollectBaseDistributionByCycle-chart-png:
    type: File
    outputSource: bams2cram/picard-CollectBaseDistributionByCycle-chart-png
  # haplotypecaller autosome-PAR, ploidy 2
  vcf_gz:
    type: File
    outputSource: haplotypecaller_autosome_PAR_ploidy_2/vcf_gz
  haplotypecaller_log:
    type: File
    outputSource: haplotypecaller_autosome_PAR_ploidy_2/haplotypecaller_log
  bgzip_log:
    type: File
    outputSource: haplotypecaller_autosome_PAR_ploidy_2/bgzip_log
  tabix_log:
    type: File
    outputSource: haplotypecaller_autosome_PAR_ploidy_2/tabix_log
  bcftools_stats:
    type: File
    outputSource: haplotypecaller_autosome_PAR_ploidy_2/bcftools_stats
  bcftools_stats_log:
    type: File
    outputSource: haplotypecaller_autosome_PAR_ploidy_2/bcftools_stats_log
  # haplotypecaller chrX-nonPAR, ploidy 2
  haplotypecaller_chrX_nonPAR_ploidy_2_vcf_gz:
    type: File
    outputSource: haplotypecaller_chrX_nonPAR_ploidy_2/vcf_gz
  haplotypecaller_chrX_nonPAR_ploidy_2_haplotypecaller_log:
    type: File
    outputSource: haplotypecaller_chrX_nonPAR_ploidy_2/haplotypecaller_log
  haplotypecaller_chrX_nonPAR_ploidy_2_bgzip_log:
    type: File
    outputSource: haplotypecaller_chrX_nonPAR_ploidy_2/bgzip_log
  haplotypecaller_chrX_nonPAR_ploidy_2_tabix_log:
    type: File
    outputSource: haplotypecaller_chrX_nonPAR_ploidy_2/tabix_log
  haplotypecaller_chrX_nonPAR_ploidy_2_bcftools_stats:
    type: File
    outputSource: haplotypecaller_chrX_nonPAR_ploidy_2/bcftools_stats
  haplotypecaller_chrX_nonPAR_ploidy_2_bcftools_stats_log:
    type: File
    outputSource: haplotypecaller_chrX_nonPAR_ploidy_2/bcftools_stats_log
  # haplotypecaller chrX-nonPAR, ploidy 1
  haplotypecaller_chrX_nonPAR_ploidy_1_vcf_gz:
    type: File
    outputSource: haplotypecaller_chrX_nonPAR_ploidy_1/vcf_gz
  haplotypecaller_chrX_nonPAR_ploidy_1_haplotypecaller_log:
    type: File
    outputSource: haplotypecaller_chrX_nonPAR_ploidy_1/haplotypecaller_log
  haplotypecaller_chrX_nonPAR_ploidy_1_bgzip_log:
    type: File
    outputSource: haplotypecaller_chrX_nonPAR_ploidy_1/bgzip_log
  haplotypecaller_chrX_nonPAR_ploidy_1_tabix_log:
    type: File
    outputSource: haplotypecaller_chrX_nonPAR_ploidy_1/tabix_log
  haplotypecaller_chrX_nonPAR_ploidy_1_bcftools_stats:
    type: File
    outputSource: haplotypecaller_chrX_nonPAR_ploidy_1/bcftools_stats
  haplotypecaller_chrX_nonPAR_ploidy_1_bcftools_stats_log:
    type: File
    outputSource: haplotypecaller_chrX_nonPAR_ploidy_1/bcftools_stats_log
  # haplotypecaller chrY-nonPAR, ploidy 1
  haplotypecaller_chrY_nonPAR_ploidy_1_vcf_gz:
    type: File
    outputSource: haplotypecaller_chrY_nonPAR_ploidy_1/vcf_gz
  haplotypecaller_chrY_nonPAR_ploidy_1_haplotypecaller_log:
    type: File
    outputSource: haplotypecaller_chrY_nonPAR_ploidy_1/haplotypecaller_log
  haplotypecaller_chrY_nonPAR_ploidy_1_bgzip_log:
    type: File
    outputSource: haplotypecaller_chrY_nonPAR_ploidy_1/bgzip_log
  haplotypecaller_chrY_nonPAR_ploidy_1_tabix_log:
    type: File
    outputSource: haplotypecaller_chrY_nonPAR_ploidy_1/tabix_log
  haplotypecaller_chrY_nonPAR_ploidy_1_bcftools_stats:
    type: File
    outputSource: haplotypecaller_chrY_nonPAR_ploidy_1/bcftools_stats
  haplotypecaller_chrY_nonPAR_ploidy_1_bcftools_stats_log:
    type: File
    outputSource: haplotypecaller_chrY_nonPAR_ploidy_1/bcftools_stats_log

