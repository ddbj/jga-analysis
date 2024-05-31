#!/usr/bin/env cwl-runner

class: CommandLineTool
id: gatk4-GnarlyGenotyper-biggest-practices.cwl
label: gatk4-GnarlyGenotyper-biggest-practices.cwl
cwlVersion: v1.1

requirements:
  DockerRequirement:
    dockerPull: us.gcr.io/broad-gatk/gatk:4.5.0.0
  ShellCommandRequirement: {}
  InlineJavascriptRequirement: {}

baseCommand: [gatk]

inputs:
  java_options:
    type: string?
    default: -Xms8000m -Xmx25000m
    inputBinding:
      position: 1
      prefix: --java-options
      shellQuote: true
  reference:
    type: File
    inputBinding:
      position: 3
      prefix: -R
    secondaryFiles:
      - .fai
      - ^.dict
  idx:
    type: int
    doc: intervals, row number
  gnarly_idx:
    type: int
    doc: intervals, one row messeage
  callset_name:
    type: string
    doc: (ex) gnarly_callset
  make_annotation_db:
    type: boolean
    default: false
    inputBinding:
      position: 5
      prefix: --output-database-name annotationDB.vcf.gz
      shellQuote: true
  dbsnp_vcf:
    type: File
    inputBinding:
      position: 6
      prefix: -D
  workspace_dir_name:
    type: string
  interval:
    type: File
    inputBinding:
      position: 9
      prefix: -L
  stand-call-conf:
    type: int
    default: 10
    inputBinding:
      position: 10
      prefix: -stand-call-conf
  max-alternate-alleles:
    type: int
    default: 5
    inputBinding:
      position: 11
      prefix: --max-alternate-alleles
  workspace_dir:
    type: Directory

outputs:
  output_vcf:
    type: File
    outputBinding:
      glob: $(inputs.callset_name).$(inputs.idx).$(inputs.gnarly_idx).vcf.gz
    secondaryFiles:
      - .tbi
  output_database:
    type: File?
    outputBinding:
      glob: annotationDB.vcf.gz
    secondaryFiles:
      - .tbi

stderr: $(inputs.callset_name).$(inputs.idx).$(inputs.gnarly_idx).vcf.gz.log

arguments:
  - position: 2
    valueFrom: GnarlyGenotyper
  - position: 4
    prefix: -O
    valueFrom: $(inputs.callset_name).$(inputs.idx).$(inputs.gnarly_idx).vcf.gz
  - position: 7
    valueFrom: --only-output-calls-starting-in-intervals
  - position: 8
    prefix: -V
    valueFrom: gendb://$(inputs.workspace_dir_name)
  - position: 12
    valueFrom: --merge-input-intervals