#!/usr/bin/env cwl-runner

class: CommandLineTool
id: RevertSam
label: RevertSam
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
    default: -Xmx1000m
  bam:
    type: File
    format: edam:format_2572
    secondaryFiles:
      - ^.bai
    inputBinding:
      position: 4
      prefix: INPUT=
      separate: false
  outprefix:
    type: string

outputs:
  unmapped_bam:
    type: File
    format: edam:format_2572
    outputBinding:
      glob: $(inputs.outprefix).bam
  log:
    type: stderr

stderr: $(inputs.outprefix).log

arguments:
  - position: 2
    prefix: -jar
    valueFrom: /usr/gitc/picard.jar
  - position: 3
    valueFrom: RevertSam
  - position: 5
    prefix: OUTPUT_BY_READGROUP=
    separate: false
    valueFrom: "false"
  - position: 6
    prefix: OUTPUT=
    separate: false
    valueFrom: $(inputs.outprefix).bam
  - position: 7
    prefix: VALIDATION_STRINGENCY=
    separate: false
    valueFrom: LENIENT
  - position: 8
    prefix: ATTRIBUTE_TO_CLEAR=
    separate: false
    valueFrom: FT
  - position: 9
    prefix: ATTRIBUTE_TO_CLEAR=
    separate: false
    valueFrom: CO
  - position: 10
    prefix: SORT_ORDER=
    separate: false
    valueFrom: queryname
  - position: 11
    prefix: RESTORE_ORIGINAL_QUALITIES=
    separate: false
    valueFrom: "false"
