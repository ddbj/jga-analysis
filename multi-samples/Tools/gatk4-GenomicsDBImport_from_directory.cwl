#!/usr/bin/env cwl-runner

class: CommandLineTool
id: gatk4-GenomicsDBImport
label: gatk4-GenomicsDBImport
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

requirements:
  DockerRequirement:
    dockerPull: broadinstitute/gatk:4.2.0.0
  ShellCommandRequirement: {}

baseCommand: /bin/bash

inputs:
  # in_gVCFs:
  #   type:
  #     type: array
  #     items: File
  #     inputBinding:
  #       prefix: -V
  #   secondaryFiles:
  #     - .tbi
  #   inputBinding:
  #     position: 4
  #   doc: gVCF files to be imported
  in_gVCFs_dir:
    type: Directory
    inputBinding:
      position: 100
  
  exec_script:
    type: File
    default:
      class: File
      location: ./genomic-db.sh
    inputBinding:
      position: 1

  outprefix:
    type: string
  
  interval_bed:
    type: File
    format: edam:format_3584
    inputBinding:
      prefix: -L
      position: 6

  batch_size:
    type: int
    default: 0
    inputBinding:
      prefix: --batch-size
      position: 7

  java_options:
    type: string?
    default: -XX:-UseContainerSupport -Xmx4g -Xms4g
    inputBinding:
      position: 1
      shellQuote: false

  # Multithreaded reader initialization does not scale well beyond 5 threads.
  num_threads:
    type: int
    default: 1
    inputBinding:
      prefix: --reader-threads
      position: 8

  interval_padding:
    type: int
    default: 0
    inputBinding:
      prefix: --interval-padding
      position: 9

#  genomicsdb_shared_posixfs_optimizations:
#    type: string
#    default: "true"
#    inputBinding:
#      prefix: --genomicsdb-shared-posixfs-optimizations
#      position: 10
      
outputs:
  genomics-db:
    type: Directory
    outputBinding:
      glob: $(inputs.outprefix).genomics-db
  log:
    type: stderr

stderr: $(inputs.outprefix).genomics-db.log

arguments:
  - position: 2
    prefix: -jar
    valueFrom: /gatk/gatk-package-4.2.0.0-local.jar
  - position: 3
    valueFrom: GenomicsDBImport
  - position: 5
    prefix: --genomicsdb-workspace-path
    valueFrom: $(inputs.outprefix).genomics-db

  
