#!/usr/bin/env cwl-runner

class: CommandLineTool
id: picard-CollectBaseDistributionByCycle-2.23.3
label: picard-CollectBaseDistributionByCycle-2.23.3
cwlVersion: v1.1

$namespaces:
  edam: 'http://edamontology.org/'

hints:
  - class: DockerRequirement
    dockerPull: 'quay.io/biocontainers/picard:2.23.3--0'

requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 20000

baseCommand: [ java, -Xmx12G, -jar, /usr/local/share/picard-2.23.3-0/picard.jar, CollectBaseDistributionByCycle ]

inputs:
  cram:
    type: File
    format: edam:format_3462
    inputBinding:
      prefix: "INPUT="
      position: 1
    doc: input CRAM alignment file
  reference:
    type: File
    format: edam:format_1929
    secondaryFiles:
      - .fai
    inputBinding:
      prefix: "REFERENCE_SEQUENCE="
      position: 2
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
    valueFrom: "CHART=$(inputs.cram.basename).collect_base_dist_by_cycle.chart.pdf"
