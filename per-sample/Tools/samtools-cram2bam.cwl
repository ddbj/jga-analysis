#!/usr/bin/env cwl-runner

class: CommandLineTool
id: samtools-cram2bam
label: samtools-cram2bam
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

requirements:
  DockerRequirement:
    dockerPull: ghcr.io/biosciencedbc/jga-analysis/fastq2cram-bqsr-haplotypecaller:1.0.0

baseCommand: [ samtools, view ]

inputs:
  cram:
    type: File
    format: edam:format_3462
    doc: CRAM to be coverted to BAM
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
  bam:
    type: File
    format: edam:format_2572
    outputBinding:
      glob: $(inputs.cram.nameroot).bam
  log:
    type: stderr

stderr: $(inputs.cram.nameroot).bam.log

arguments:
  - position: 3
    valueFrom: -b
  - position: 4
    valueFrom: -h
  - position: 5
    prefix: -o
    valueFrom: $(inputs.cram.nameroot).bam
