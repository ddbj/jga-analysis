#!/usr/bin/env cwl-runner

class: CommandLineTool
id: gatk4-GenomicsDBImport
label: gatk4-GenomicsDBImport
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

requirements:
  DockerRequirement:
    dockerPull: ghcr.io/tafujino/jga-analysis/fastq2cram_haplotypecaller:latest
  ShellCommandRequirement: {}

baseCommand: /usr/bin/java

inputs:
  in_gVCFs:
    type:
      type: array
      items: File
      inputBinding:
        prefix: -V=
        separate: false
    secondaryFiles:
      - .tbi
    inputBinding:
      position: 4
    doc: gVCF files to be imported

  outprefix:
    type: string
  
  interval_bed:
    type: File
    format: edam:format_3584
    inputBinding:
      prefix: -L=
      separate: false
      position: 6

  batch_size:
    type: int
    default: 0
    inputBinding:
      prefix: --batch-size=
      separate: false
      position: 7

  java_options:
    type: string?
    default: -XX:-UseContainerSupport -Xmx14g
    inputBinding:
      position: 1
      shellQuote: false

  num_threads:
    type: int
    default: 1
    inputBinding:
      prefix: --reader-threads=
      separate: false
      position: 8

  interval_padding:
    type: int
    default: 0
    inputBinding:
      prefix: --interval-padding=
      separate: false
      position: 9
      
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
    valueFrom: /tools/gatk-4.1.0.0/gatk-package-4.1.0.0-local.jar
  - position: 3
    valueFrom: GenomicsDBImport
  - position: 5
    prefix: --genomicsdb-workspace-path=
    separate: false
    valueFrom: $(inputs.outprefix).genomics-db

  
