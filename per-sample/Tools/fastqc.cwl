#!/usr/bin/env cwl-runner

class: CommandLineTool
id: fastqc
label: fastqc
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

requirements:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/fastqc:0.11.9--hdfd78af_1
  InitialWorkDirRequirement:
    listing:
      - $(inputs.fastq)

baseCommand: [ fastqc ]

inputs:
  fastq:
    type: File
    format: edam:format_1930
    doc: FastQ file from next-generation sequencers
    inputBinding:
      position: 1
  num_threads:
    type: int
    default: 1
    inputBinding:
      prefix: -t
      position: 2

outputs:
  html:
    type: File
    outputBinding:
      glob: '*_fastqc.html'
    format: edam:format_2331
  log:
    type: stderr

stderr: $(inputs.fastq.nameroot).fastqc.log
