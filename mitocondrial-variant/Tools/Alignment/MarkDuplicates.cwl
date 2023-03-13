#!/usr/bin/env cwl-runner

class: CommandLineTool
id: MarkDuplicates
label: MarkDuplicates
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

hints:
  - class: DockerRequirement
    dockerPull: us.gcr.io/broad-gotc-prod/genomes-in-the-cloud:2.4.2-1552931386

requirements:
  ShellCommandRequirement: {}

baseCommand: [java]

inputs:
  java_options:
    type: string?
    inputBinding:
      position: 1
      shellQuote: false
    default: -Xms4000m
  in_bam:
    type: File
    format: edam:format_2572
    inputBinding:
      position: 4
      prefix: INPUT=
      separate: false
  read_name_regex:
    type: string?
    inputBinding:
      position: 8
      prefix: READ_NAME_REGEX=
      separate: false
  outprefix:
    type: string

outputs:
  out_bam:
    type: File
    format: edam:format_2572
    outputBinding:
      glob: md.bam
  duplicate_metrics:
    type: File
    outputBinding:
      glob: $(inputs.outprefix).duplicate_metrics
  log:
    type: stderr

stderr: $(inputs.outprefix).duplicate_metrics.log

arguments:
  - position: 2
    prefix: -jar
    valueFrom: /usr/gitc/picard.jar
  - position: 3
    valueFrom: MarkDuplicates
  - position: 5
    prefix: OUTPUT=
    separate: false
    valueFrom: md.bam
  - position: 6
    prefix: METRICS_FILE=
    separate: false
    valueFrom: $(inputs.outprefix).duplicate_metrics
  - position: 7
    prefix: VALIDATION_STRINGENCY=
    separate: false
    valueFrom: SILENT
  - position: 9
    prefix: OPTICAL_DUPLICATE_PIXEL_DISTANCE=
    separate: false
    valueFrom: "2500"
  - position: 10
    prefix: ASSUME_SORT_ORDER=
    separate: false
    valueFrom: queryname
  - position: 11
    prefix: CLEAR_DT=
    separate: false
    valueFrom: "false"
  - position: 12
    prefix: ADD_PG_TAG_TO_READS=
    separate: false
    valueFrom: "false"
