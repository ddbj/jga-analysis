#!/usr/bin/env cwl-runner

class: CommandLineTool
id: gatk4-VariantFiltration-biggest-practices
label: gatk4-VariantFiltration-biggest-practices
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
    default: -Xms3000m -Xmx3250m
    inputBinding:
      position: 1
      prefix: --java-options
      shellQuote: true
  filter-expression:
    type: float
    default: 54.69
    inputBinding:
      position: 3
      prefix: --filter-expression
      valueFrom: ExcessHet > $(self)
      shellQuote: false
  targets_interval_list:
    type: File
    inputBinding:
      position: 5
      prefix: --filter-not-in-mask --mask-name OUTSIDE_OF_TARGETS --mask
      shellQuote: false
  vcf:
    type: File
    inputBinding:
      position: 7
      prefix: "-V"
    secondaryFiles:
      - .tbi
  callset_name:
    type: string
    doc: (ex) gnarly_callset
  idx:
    type: int
    doc: unpadded_intervals, row number

outputs:
  variant_filtered_vcf:
    type: File
    outputBinding:
      glob: $(inputs.callset_name).$(inputs.idx).variant_filtered.vcf.gz
    secondaryFiles:
      - .tbi

stderr: $(inputs.callset_name).$(inputs.idx).variant_filtered.vcf.gz.log

arguments:
  - position: 2
    valueFrom: VariantFiltration
  - position: 4
    valueFrom: --filter-name ExcessHet
    shellQuote: false
  - position: 6
    prefix: -O
    valueFrom: $(inputs.callset_name).$(inputs.idx).variant_filtered.vcf.gz