#!/usr/bin/env cwl-runner

class: CommandLineTool
id: samtools-flagstat-1.6
label: samtools-flagstat-1.6
cwlVersion: v1.1

$namespaces:
  edam: 'http://edamontology.org/'

hints:
  - class: DockerRequirement
    dockerPull: 'quay.io/biocontainers/samtools:1.6--0'

requirements:
  - class: ShellCommandRequirement

baseCommand: [ samtools, flagstat ]

inputs:
  - id: nthreads
    type: int
    default: 1
    inputBinding:
      prefix: --threads
      position: 1
  - id: cram
    type: File
    format: edam:format_3462
    inputBinding:
      position: 2
    doc: input CRAM alignment file

outputs:
  - id: flagstat
    type: stdout

stdout: $(inputs.cram.basename).flagstat

arguments: []
