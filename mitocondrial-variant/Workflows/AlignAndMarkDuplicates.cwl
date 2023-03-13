#!/usr/bin/env cwl-runner

class: Workflow
id: AlignAndMarkDuplicates
label: AlignAndMarkDuplicates
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

inputs:
  reference:
    type: File
    format: edam:format_1929
    secondaryFiles:
      - .fai
      - ^.dict
      - .amb
      - .ann
      - .bwt
      - .pac
      - .sa
  unmapped_bam:
    type: File
    format: edam:format_2572
  read_name_regex:
    type: string?
  outprefix:
    type: string

steps:
  Align:
    label: Align
    run: ../Tools/Alignment/Align.cwl
    in:
      reference: reference
      unmapped_bam: unmapped_bam
      outprefix: outprefix
    out: [bam, BWA_log, log]
  MarkDuplicates:
    label: MarkDuplicates
    run: ../Tools/Alignment/MarkDuplicates.cwl
    in:
      in_bam: Align/bam
      outprefix: outprefix
    out: [out_bam, duplicate_metrics, log]
  SortSam:
    label: SortSam
    run: ../Tools/Alignment/SortSam.cwl
    in:
      in_bam: MarkDuplicates/out_bam
      outprefix: outprefix
    out: [out_bam, log]

outputs:
  bam:
    type: File
    outputSource: SortSam/out_bam
    secondaryFiles:
      - ^.bai
  duplicate_metrics:
    type: File
    outputSource: MarkDuplicates/duplicate_metrics
  BWA_log:
    type: File
    outputSource: Align/BWA_log
  #
  # The followings are not listed in the original WDL
  #
  Align_log:
    type: File
    outputSource: Align/log
  MarkDuplicates_log:
    type: File
    outputSource: MarkDuplicates/log
  SortSam_log:
    type: File
    outputSource: SortSam/log
