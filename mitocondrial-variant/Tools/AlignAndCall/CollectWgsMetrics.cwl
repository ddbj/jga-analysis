#!/usr/bin/env cwl-runner

class: CommandLineTool
id: CollectWgsMetrics
label: CollectWgsMetrics
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
    default: -Xmx2000m
  bam:
    type: File
    format: edam:format_2572
    secondaryFiles:
      - ^.bai
    inputBinding:
      position: 4
      prefix: INPUT=
      separate: false
  reference:
    type: File
    format: edam:format_1929
    secondaryFiles:
      - .fai
    inputBinding:
      position: 6
      prefix: REFERENCE_SEQUENCE=
      separate: false
  read_length:
    type: int?
    inputBinding:
      position: 9
      prefix: READ_LENGTH=
      separate: false
    default: 151
  coverage_cap:
    type: int?
    inputBinding:
      position: 10
      prefix: COVERAGE_CAP=
      separate: false

outputs:
  coverage_metrics:
    type: File
    outputBinding:
      glob: $(inputs.bam.nameroot).coverage_metrics
  theoretical_sensitivity:
    type: File
    outputBinding:
      glob: $(inputs.bam.nameroot).theoretical_sensitivity
  log:
    type: stderr

stderr: $(inputs.bam.nameroot).coverage_metrics.log

arguments:
  - position: 2
    prefix: -jar
    valueFrom: /usr/gitc/picard.jar
  - position: 3
    valueFrom: CollectWgsMetrics
  - position: 5
    prefix: VALIDATION_STRINGENCY=
    separate: false
    valueFrom: SILENT
  - position: 7
    prefix: OUTPUT=
    separate: false
    valueFrom: $(inputs.bam.nameroot).coverage_metrics
  - position: 8
    prefix: USE_FAST_ALGORITHM=
    separate: false
    valueFrom: "true"
  - position: 11
    prefix: INCLUDE_BQ_HISTOGRAM=
    separate: false
    valueFrom: "true"
  - position: 12
    prefix: THEORETICAL_SENSITIVITY_OUTPUT=
    separate: false
    valueFrom: $(inputs.bam.nameroot).theoretical_sensitivity
