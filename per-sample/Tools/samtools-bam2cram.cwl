#!/usr/bin/env cwl-runner

class: CommandLineTool
id: samtools-bam2cram
label: samtools-bam2cram
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

hints:
  DockerRequirement:
    dockerPull: ghcr.io/tafujino/jga-analysis/fastq2cram:latest

baseCommand: [ samtools, view ]

inputs:
  bam:
    type: File
    format: edam:format_2572
    doc: BAM to be coverted to CRAM
    inputBinding:
      position: 1
  reference:
    type: File
    format: edam:format_1929
    doc: FastA file for reference genome
    secondaryFiles:
      - .fai
    inputBinding:
      prefix: -T
      position: 2
  num_threads:
    type: int
    default: 1
    inputBinding:
      prefix: -@
      position: 5

outputs:
  cram:
    type: File
    format: edam:format_3462
    outputBinding:
      glob: $(inputs.bam.nameroot).cram
  log:
    type: stderr

stderr: $(inputs.bam.nameroot).cram.log

arguments:
  - position: 3
    valueFrom: -C
  - position: 4
    prefix: -o
    valueFrom: $(inputs.bam.nameroot).cram
