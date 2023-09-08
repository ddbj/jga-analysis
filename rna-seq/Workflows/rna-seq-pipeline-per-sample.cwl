#!/usr/bin/env cwl-runner

class: Workflow
id: rna-seq-pipeline-per-sample_PE
label: rna-per-sample_PE
cwlVersion: v1.2

inputs:
  fastqs_R1:
    type: File[]
  fastqs_R2:
    type: File[]
  endedness:
    type: string
  index:
    type: File
  bamroot:
    type: string
  ncpus:
    type: int
  ramGB:
    type: int

# endednessの値がpairedか、singleかでstepsのrunで実行するcwlファイルを変えたい

steps:
  align:
    run: ../Tools/align_PE.cwl
    in:
      fastqs_R1: fastqs_R1
      fastqs_R2: fastqs_R2
      endedness: endedness
      index: index
      bamroot: bamroot
      ncpus: ncpus
      ramGB: ramGB
    out:
      - genomebam
      - annobam
      - genome_flagstat
      - anno_flagstat
      - log
      - genome_flagstat_json
      - anno_flagstat_json
      - log_json
      - python_log

outputs:
  genomebam:
    type: File
    outputSource: align/genomebam
  annobam:
    type: File
    outputSource: align/annobam
  genome_flagstat:
    type: File
    outputSource: align/genome_flagstat
  anno_flagstat:
    type: File
    outputSource: align/anno_flagstat
  log:
    type: File
    outputSource: align/log
  genome_flagstat_json:
    type: File
    outputSource: align/genome_flagstat_json
  anno_flagstat_json:
    type: File
    outputSource: align/anno_flagstat_json
  log_json:
    type: File
    outputSource: align/log_json
  python_log:
    type: File
    outputSource: align/python_log
