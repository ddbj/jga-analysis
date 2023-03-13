#!/usr/bin/env cwl-runner

class: CommandLineTool
id: SortSam
label: SortSam
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
  outprefix:
    type: string

outputs:
  out_bam:
    type: File
    format: edam:format_2572
    outputBinding:
      glob: $(inputs.outprefix).bam
    secondaryFiles:
      - ^.bai
  log:
    type: stderr

stderr: $(inputs.outprefix).SortSam.log

arguments:
  - position: 2
    prefix: -jar
    valueFrom: /usr/gitc/picard.jar
  - position: 3
    valueFrom: SortSam
  - position: 5
    prefix: OUTPUT=
    separate: false
    valueFrom: $(inputs.outprefix).bam
  - position: 6
    prefix: SORT_ORDER=
    separate: false
    valueFrom: coordinate
  - position: 7
    prefix: CREATE_INDEX=
    separate: false
    valueFrom: "true"
  - position: 8
    prefix: MAX_RECORDS_IN_RAM=
    separate: false
    valueFrom: "300000"
