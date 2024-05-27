#!/usr/bin/env cwl-runner

class: CommandLineTool
id: gatk4-GenomicsDBImport-biggest-practices
label: gatk4-GenomicsDBImport-biggest-practices
cwlVersion: v1.1

requirements:
  DockerRequirement:
    dockerPull: us.gcr.io/broad-gatk/gatk:4.5.0.0
  ShellCommandRequirement: {}

baseCommand: java

inputs:
  java_options:
    type: string?
    default: -XX:-UseContainerSupport -Xmx25g -Xms8g
    inputBinding:
      position: 1
      shellQuote: false
  workspace_dir_name:
    type: string
    inputBinding:
      position: 4
      prefix: --genomicsdb-workspace-path
  batch_size:
    type: int
    default: 50
    inputBinding:
      prefix: --batch-size
      position: 5
  interval:
    type: string
    inputBinding:
      position: 6
      prefix: -L
  sample_name_map:
    type: File
    inputBinding:
      position: 7
      prefix: --sample-name-map
  num_threads:
    type: int
    default: 5
    inputBinding:
      prefix: --reader-threads
      position: 8

outputs:
  genomics-db:
    type: Directory
    outputBinding:
      glob: $(inputs.workspace_dir_name)

arguments:
  - position: 2
    prefix: -jar
    valueFrom: /gatk/gatk-package-4.5.0.0-local.jar
  - position: 3
    valueFrom: GenomicsDBImport
  - position: 9
    valueFrom: --merge-input-intervals
  - position: 10
    valueFrom: --consolidate