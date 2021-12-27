#!/usr/bin/env cwl-runner

class: CommandLineTool
id: samtools-index
label: samtools-index
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

requirements:
  DockerRequirement:
    dockerPull: ghcr.io/biosciencedbc/jga-analysis/fastq2cram-bqsr-haplotypecaller:1.0.0
  InitialWorkDirRequirement:
    listing: [ $(inputs.cram) ]
  ResourceRequirement:
    coresMin: $(inputs.num_threads)
    ramMin: $(inputs.ram_min)

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
  ram_min:
    type: int
    default: 48000
outputs:
  indexed_cram:
    type: File
    format: edam:format_3462
    outputBinding:
      glob: $(inputs.cram.basename)
    secondaryFiles:
      - .crai
  log:
    type: stderr

stderr: $(inputs.cram.basename).crai.log
