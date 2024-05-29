#!/usr/bin/env cwl-runner

class: CommandLineTool
id: gatk4-GenomicsDBImport-biggest-practices
label: gatk4-GenomicsDBImport-biggest-practices
cwlVersion: v1.1

requirements:
  DockerRequirement:
    dockerPull: us.gcr.io/broad-gatk/gatk:4.5.0.0
  ShellCommandRequirement: {}

baseCommand: [gatk]

inputs:
  java_options:
    type: string?
    default: -Xms8000m -Xmx25000m
    inputBinding:
      position: 1
      prefix: --java-options
      shellQuote: true
  workspace_dir_name:
    type: string
    inputBinding:
      position: 3
      prefix: --genomicsdb-workspace-path
  batch_size:
    type: int
    default: 50
    inputBinding:
      prefix: --batch-size
      position: 4
  interval:
    type: string
    inputBinding:
      position: 5
      prefix: -L
  sample_name_map:
    type: File
    inputBinding:
      position: 6
      prefix: --sample-name-map
  num_threads:
    type: int
    default: 5
    inputBinding:
      prefix: --reader-threads
      position: 7

outputs:
  genomics-db:
    type: Directory
    outputBinding:
      glob: $(inputs.workspace_dir_name)

arguments:
  - position: 2
    valueFrom: GenomicsDBImport
  - position: 8
    valueFrom: --merge-input-intervals
  - position: 9
    valueFrom: --consolidate