#!/usr/bin/env cwl-runner

class: CommandLineTool
id: rnaseq_samtools_quickcheck
label: samtools_quickcheck
cwlVersion: v1.2

requirements:
  ResourceRequirement:
    ramMin: 64
    coresMin: 16
  DockerRequirement:
    dockerPull: docker://encodedcc/rna-seq-pipeline:1.2.4

baseCommand: [samtools, quickcheck]

inputs:
  bam:
    type: File
    inputBinding:
      position: 1
  ncpus:
    type: int
  ramGB:
    type: int
  disks:  
    type: string?
    default: "local-disk 100 SSD"

outputs: []
