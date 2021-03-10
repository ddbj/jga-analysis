#!/usr/bin/env cwl-runner

class: Workflow
id: bams2cram-with-bqsr
label: bams2cram-with-bqsr
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

requirements:
  - class: StepInputExpressionRequirement
  
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
  
  gatk4-MarkDuplicates_java_options:
    type: string?
  
  gatk4-BaseRecalibrator_java_options:
    type: string?
  
  gatk4-ApplyBQSR_java_options:
    type: string?
  
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
      outprefix:
        source: outprefix
        valueFrom: $(inputs.outprefix).gatk4-MarkDuplicates
      java_options: gatk4-MarkDuplicates_java_options
    out:
      [markdup_bam, metrics, log]

  gatk4-BaseRecalibrator:
    label: gatk4-BaseRecalibrator
    doc: Generates recalibration table for Base Quality Score Recalibration (BQSR)
    run: ../Tools/gatk4-BaseRecalibrator.cwl
    in:
      reference: reference
      bam: gatk4-MarkDuplicates/markdup_bam
      use_original_qualities: use_original_qualities
      dbsnp: dbsnp
      mills: mills
      known_indels: known_indels
      outprefix:
        source: outprefix
        valueFrom: $(inputs.outprefix).gatk4-BaseRecalibrator
      java_options: gatk4-BaseRecalibrator_java_options
    out:
      [table, log]

  gatk4-ApplyBQSR:
    label: gatk4-ApplyBQSR
    doc: Apply base quality score recalibration
    run: ../Tools/gatk4-ApplyBQSR.cwl
    in:
      reference: reference
      bam: gatk4-MarkDuplicates/markdup_bam
      use_original_qualities: use_original_qualities
      bqsr: gatk4-BaseRecalibrator/table
      outprefix: outprefix
      java_options: gatk4-ApplyBQSR_java_options
    out:
      [out_bam, log]
      
  samtools-bam2cram:
    label: samtools-bam2cram
    doc: Coverts BAM to CRAM
    run: ../Tools/samtools-bam2cram.cwl
    in:
      bam: gatk4-ApplyBQSR/out_bam
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
      [crai, log]

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
    outputSource: samtools-bam2cram/cram
  cram_log:
    type: File
    outputSource: samtools-bam2cram/log
  crai:
    type: File
    outputSource: samtools-index/crai
  crai_log:
    type: File
    outputSource: samtools-index/log
  base-recalibrator_log:
    type: File
    outputSource: gatk4-BaseRecalibrator/log
  apply-bqsr/log:
    type: File
    outputSource: gatk4-ApplyBQSR/log
