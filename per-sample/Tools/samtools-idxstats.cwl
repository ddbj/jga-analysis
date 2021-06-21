#!/usr/bin/env cwl-runner

class: CommandLineTool
id: samtools-idxstats-1.10
label: samtools-idxstats-1.10
cwlVersion: v1.0

$namespaces:
  edam: 'http://edamontology.org/'

hints:
  - class: DockerRequirement
    dockerPull: 'quay.io/biocontainers/samtools:1.10--h9402c20_2'

requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 4000

baseCommand: [ samtools, idxstats ]

inputs:
  cram:
    type: File
    format: edam:format_3462
    inputBinding:
      position: 1
    doc: input CRAM alignment file
    secondaryFiles:
      - .crai

outputs:
  idxstats:
    type: stdout

stdout: $(inputs.cram.basename).idxstats

arguments: []
