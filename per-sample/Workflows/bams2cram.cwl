#!/usr/bin/env cwl-runner

class: Workflow
id: bams2cram
label: bams2cram
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

requirements:
  StepInputExpressionRequirement: {}

inputs:
  reference:
    type: File
    format: edam:format_1929
    doc: FastA file for reference genome
    secondaryFiles:
      - .fai
      - ^.dict
  bams:
    type:
      type: array
      items: File
    doc: BAM files to be merged
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
  outprefix:
    type: string
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

steps:
  gatk4-MarkDuplicates:
    label: gatk4-MarkDuplicates
    doc: Merges multiple BAMs and mark duplicates
    run: ../Tools/gatk4-MarkDuplicates.cwl
    in:
      in_bams: bams
      outprefix: outprefix
      java_options: gatk4_MarkDuplicates_java_options
    out:
      [markdup_bam, metrics, log]
  gatk4-optional-bqsr:
    label: gatk4-optional-bqsr
    doc: Generates BQSR table and applies BQSR to BAM if required
    run: ../Tools/gatk4-optional-bqsr.cwl
    in:
      use_bqsr: use_bqsr
      reference: reference
      bam: gatk4-MarkDuplicates/markdup_bam
      use_original_qualities: use_original_qualities
      dbsnp: dbsnp
      mills: mills
      known_indels: known_indels
      outprefix: outprefix
      gatk4_BaseRecalibrator_java_options: gatk4_BaseRecalibrator_java_options
      gatk4_ApplyBQSR_java_options: gatk4_ApplyBQSR_java_options
      static_quantized_quals: static_quantized_quals
    out:
      [out_bam, log]
  samtools-bam2cram:
    label: samtools-bam2cram
    doc: Coverts BAM to CRAM
    run: ../Tools/samtools-bam2cram.cwl
    in:
      bam: gatk4-optional-bqsr/out_bam
      reference: reference
      num_threads: samtools_num_threads
    out:
      [cram, log]
  samtools-index:
    label: samtools-index
    doc: Indexes CRAM
    run: ../Tools/samtools-index.cwl
    in:
      cram: samtools-bam2cram/cram
      num_threads: samtools_num_threads
    out:
      [indexed_cram, log]
  samtools-idxstats:
    label: samtools-idxstats
    doc: Calculate idxstats using samtools
    run: ../Tools/samtools-idxstats.cwl
    in:
      cram: samtools-index/indexed_cram
    out:
      [idxstats]
  samtools-flagstat:
    label: samtools-flagstat
    doc: Calculate flagstat using samtools
    run: ../Tools/samtools-flagstat.cwl
    in:
      cram: samtools-index/indexed_cram
    out:
      [flagstat]
  picard-CollectBaseDistributionByCycle:
    label: picard-CollectBaseDistributionByCycle
    doc: Collect base distribution by cycle using Picard
    run: ../Tools/picard-CollectBaseDistributionByCycle.cwl
    in:
      cram: samtools-index/indexed_cram
      reference: reference
    out:
      [collect_base_dist_by_cycle, chart]
  picard-CollectBaseDistributionByCycle-pdf2png:
    label: picard-CollectBaseDistributionByCycle-pdf2png
    doc: Convert picard-CollectBaseDistributionByCycle PDF chart to PNG
    run: ../Tools/pdf2png.cwl
    in:
      pdf: picard-CollectBaseDistributionByCycle/chart
    out:
      [png]

outputs:
  markdup_metrics:
    type: File
    outputSource: gatk4-MarkDuplicates/metrics
  markdup_log:
    type: File
    outputSource: gatk4-MarkDuplicates/log
  cram:
    type: File
    format: edam:format_3462
    outputSource: samtools-index/indexed_cram
  cram_log:
    type: File
    outputSource: samtools-bam2cram/log
  crai_log:
    type: File
    outputSource: samtools-index/log
  bqsr_log:
    type: File
    outputSource: gatk4-optional-bqsr/log
  samtools_idxstats_idxstats:
    type: File
    outputSource: samtools-idxstats/idxstats
  samtools_flagstat_flagstat:
    type: File
    outputSource: samtools-flagstat/flagstat
  picard-CollectBaseDistributionByCycle-collect_base_dist_by_cycle:
    type: File
    outputSource: picard-CollectBaseDistributionByCycle/collect_base_dist_by_cycle
  picard-CollectBaseDistributionByCycle-chart-pdf:
    type: File
    outputSource: picard-CollectBaseDistributionByCycle/chart
  picard-CollectBaseDistributionByCycle-chart-png:
    type: File
    outputSource: picard-CollectBaseDistributionByCycle-pdf2png/png
