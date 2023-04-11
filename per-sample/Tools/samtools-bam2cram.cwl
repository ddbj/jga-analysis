#!/usr/bin/env cwl-runner

class: CommandLineTool
id: samtools-bam2cram
label: samtools-bam2cram
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

requirements:
  DockerRequirement:
    dockerPull: ghcr.io/ddbj/jga-analysis/fastq2cram-bqsr-haplotypecaller:1.0.0
  ResourceRequirement:
    coresMin: $(inputs.num_threads)
    ramMin: $(inputs.ram_min)

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
  ram_min:
    type: int
    default: 48000

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
