#!/usr/bin/env cwl-runner

class: CommandLineTool
id: picard-CollectWgsMetrics-gatk.4.2.0.0
label: picard-CollectWgsMetrics-gatk.4.2.0.0
cwlVersion: v1.1

$namespaces:
  edam: 'http://edamontology.org/'

hints:
  - class: DockerRequirement
    dockerPull: 'broadinstitute/gatk:4.2.0.0'

requirements:
  - class: ShellCommandRequirement

baseCommand: [ java, -jar, /gatk/gatk-package-4.2.0.0-local.jar, CollectWgsMetrics ]

inputs:
  - id: cram
    type: File
    format: edam:format_3462
    inputBinding:
      prefix: "I="
      position: 1
      separate: false
    doc: input CRAM alignment file
  - id: reference
    type: File
    format: edam:format_1929
    inputBinding:
      prefix: "R="
      position: 3
      separate: false
    secondaryFiles:
      - .fai
    doc: FastA file for reference genome
  - id: interval_name
    type: string
    doc: Interval name for reference genome
  - id: interval_list
    type: File
    inputBinding:
      prefix: "INTERVALS="
      position: 4
      separate: false
    doc: Interval list for reference genome

outputs:
  - id: wgs_metrics
    type: File
    outputBinding:
      glob: $(inputs.cram.basename).$(inputs.interval_name).wgs_metrics
  - id: log
    type: stderr

stderr: $(inputs.cram.basename).$(inputs.interval_name).wgs_metrics.log

arguments:
  - position: 2
    valueFrom: "O=$(inputs.cram.basename).$(inputs.interval_name).wgs_metrics"
  - position: 5
    valueFrom: "TMP_DIR=temp"
  - position: 6
    valueFrom: "VALIDATION_STRINGENCY=LENIENT"
