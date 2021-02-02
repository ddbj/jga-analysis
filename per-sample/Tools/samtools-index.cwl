#!/usr/bin/env cwl-runner

class: CommandLineTool
id: samtools-index
label: samtools-index
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

hints:
  DockerRequirement:
    dockerPull: ghcr.io/biosciencedbc/jga-analysis/fastq2cram:latest

baseCommand: [ samtools, index ]

inputs:
  cram:
    type: File
    format: edam:format_3462
    inputBinding:
      position: 1
  num_threads:
    type: int
    default: 1
    inputBinding:
      prefix: -@
      position: 2

outputs:
  crai:
    type: File
    outputBinding:
      glob: $(inputs.cram.basename).crai
  log:
    type: stderr

stderr: $(inputs.cram.basename).crai.log

arguments:
  - position: 3
    valueFrom: $(inputs.cram.basename).crai
