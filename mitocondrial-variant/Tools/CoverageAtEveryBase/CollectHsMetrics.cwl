#!/usr/bin/env cwl-runner

class: CommandLineTool
id: CollectHsMetrics
label: CollectHsMetrics
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

hints:
  - class: DockerRequirement
    dockerPull: us.gcr.io/broad-gotc-prod/genomes-in-the-cloud:2.4.2-1552931386

requirements:
  ShellCommandRequirement: {}

baseCommand: [java, -jar, /usr/gitc/picard.jar]

inputs:
  reference:
    type: File
    format: edam:format_1929
    secondaryFiles:
      - .fai
      - .amb
      - .ann
      - .bwt
      - .pac
      - .sa
      - ^.dict
    inputBinding:
      position: 3
      prefix: R=
      separate: false
  bam:
    type: File
    format: edam:format_2572
    secondaryFiles:
      - ^.bai
    inputBinding:
      position: 2
      prefix: I=
      separate: false
  interval_list:
    type: File
  outprefix:
    type: string

outputs:
  per_base_coverage:
    type: File
    format: edam:format_3475
    outputBinding:
      glob: $(inputs.outprefix).tsv
  metrics:
    type: File
    outputBinding:
      glob: $(inputs.outprefix).metrics
  log:
    type: stderr

stderr: $(inputs.outprefix).log

arguments:
  - position: 1
    valueFrom: CollectHsMetrics
  - position: 4
    prefix: PER_BASE_COVERAGE=
    separate: false
    valueFrom: $(inputs.outprefix).tsv
  - position: 5
    prefix: O=
    separate: false
    valueFrom: $(inputs.outprefix).metrics
  - position: 6
    prefix: TI=
    separate: false
    valueFrom: $(inputs.interval_list)
  - position: 7
    prefix: BI=
    separate: false
    valueFrom: $(inputs.interval_list)
  - position: 8
    prefix: COVMAX=
    separate: false
    valueFrom: "20000"
  - position: 9
    prefix: SAMPLE_SIZE=
    separate: false
    valueFrom: "1"
