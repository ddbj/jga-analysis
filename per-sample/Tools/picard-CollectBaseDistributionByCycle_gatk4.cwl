#!/usr/bin/env cwl-runner

class: CommandLineTool
id: picard-CollectBaseDistributionByCycle-gatk.4.2.0.0
label: picard-CollectBaseDistributionByCycle-gatk.4.2.0.0
cwlVersion: v1.1

$namespaces:
  edam: 'http://edamontology.org/'

hints:
  - class: DockerRequirement
    dockerPull: 'broadinstitute/gatk:4.2.0.0'

requirements:
  - class: ShellCommandRequirement

baseCommand: [ java, -Xmx12G, -jar, /gatk/gatk-package-4.2.0.0-local.jar, CollectBaseDistributionByCycle ]

inputs:
  cram:
    type: File
    format: edam:format_3462
    inputBinding:
      prefix: "I="
      position: 1
      separate: false
    doc: input CRAM alignment file
  reference:
    type: File
    format: edam:format_1929
    secondaryFiles:
      - .fai
    inputBinding:
      prefix: "R="
      position: 2
      separate: false
    doc: FastA file for reference genome

outputs:
  collect_base_dist_by_cycle:
    type: File
    outputBinding:
      glob: $(inputs.cram.basename).collect_base_dist_by_cycle
  chart:
    type: File
    format: edam:format_3508
    outputBinding:
      glob: $(inputs.cram.basename).collect_base_dist_by_cycle.chart.pdf
  log:
    type: stderr

stderr: $(inputs.cram.basename).collect_base_dist_by_cycle.log

arguments:
  - position: 3
    valueFrom: "OUTPUT=$(inputs.cram.basename).collect_base_dist_by_cycle"
  - position: 4
    valueFrom: "CHART_OUTPUT=$(inputs.cram.basename).collect_base_dist_by_cycle.chart.pdf"
