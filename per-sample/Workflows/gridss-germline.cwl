#!/usr/bin/env cwl-runner

class: Workflow
id: gridss-germline
label: gridss-germline
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

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
      - .fai
  cram:
    type: File
    format: edam:format_3462
    secondaryFiles:
      - .crai
  num_threads:
    type: int
    default: 1
  java_tool_options:
    type: string
    default: ''
  jvm_heap:
    type: string
    default: 25g

steps:
  samtools-cram2bam:
    label: samtools-cram2bam
    run: ../Tools/samtools-cram2bam.cwl
    in:
      cram: cram
      reference: reference
      num_threads: num_threads
    out: [bam, log]
  gridss-germline:
    label: gridss-germline
    run: ../Tools/gridss-germline.cwl
    in:
      reference: reference
      bam: samtools-cram2bam/bam
      num_threads: num_threads
      java_tool_options: java_tool_options
      jvm_heap: jvm_heap
    out: [vcf, idx, log]

outputs:
  cram2bam_log:
    type: File
    outputSource: samtools-cram2bam/log
  vcf:
    type: File
    format: edam:format_3016
    outputSource: gridss-germline/vcf
  idx:
    type: File
    outputSource: gridss-germline/idx
  gridss-germline-log:
    type: File
    outputSource: gridss-germline/log
