#!/usr/bin/env cwl-runner

class: Workflow
id: bams2cram
label: bams2cram
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

inputs:
  reference:
    type: File
    format: edam:format_1929
    doc: FastA file for reference genome
    secondaryFiles:
      - .fai
  bams:
    type:
      type: array
      items: File
    doc: BAM files to be merged
  outprefix:
    type: string
  gatk4-MarkDuplicates_java_options:
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
      outprefix: outprefix
      java_options: gatk4-MarkDuplicates_java_options
    out:
      [markdup_bam, metrics, log]
  samtools-bam2cram:
    label: samtools-bam2cram
    doc: Coverts BAM to CRAM
    run: ../Tools/samtools-bam2cram.cwl
    in:
      bam: gatk4-MarkDuplicates/markdup_bam
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
