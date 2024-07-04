#!/usr/bin/env cwl-runner

class: CommandLineTool
id: gatk4-ApplyRecalibration-SNP-biggest-practices
label: gatk4-ApplyRecalibration-SNP-biggest-practices
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
    default: -Xms5000m -Xmx6500m
    inputBinding:
      position: 1
      prefix: --java-options
      shellQuote: true
  tmp_indel_recalibrated_vcf:
    type: File
    inputBinding:
      position: 4
      prefix: -V
    secondaryFiles:
      - .idx
  snps_recalibration:
    type: File
    inputBinding:
      position: 5
      prefix: --recal-file
  allele_specific_annotations:
    type: boolean
    default: false
    inputBinding:
      position: 6
      prefix: --use-allele-specific-annotations
  snps_tranches:
    type: File
    inputBinding:
      position: 7
      prefix: --tranches-file
  snp_filter_level:
    type: float
    default: 99.7
    inputBinding:
      position: 8
      prefix: --truth-sensitivity-filter-level
  create-output-variant-index:
    type: string?
    default: "true"
    inputBinding:
      position: 9
      prefix: --create-output-variant-index
      shellQuote: false
  callset_name:
    type: string
    doc: (ex) gnarly_callset
  idx:
    type: int
    doc: unpadded_intervals, row number

outputs:
  recalibrated_vcf_filename:
    type: File
    outputBinding:
      glob: $(inputs.callset_name).filtered.$(inputs.idx).vcf.gz
    secondaryFiles:
      - .tbi

stderr: $(inputs.callset_name).filtered.$(inputs.idx).vcf.gz.log

arguments:
  - position: 2
    valueFrom: ApplyVQSR
  - position: 3
    prefix: -O
    valueFrom: $(inputs.callset_name).filtered.$(inputs.idx).vcf.gz
  - position: 10
    prefix: -mode
    valueFrom: SNP