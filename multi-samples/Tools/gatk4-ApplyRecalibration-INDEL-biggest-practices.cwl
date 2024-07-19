#!/usr/bin/env cwl-runner

class: CommandLineTool
id: gatk4-ApplyRecalibration-INDEL-biggest-practices
label: gatk4-ApplyRecalibration-INDEL-biggest-practices
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
  input_vcf:
    type: File
    inputBinding:
      position: 4
      prefix: -V
    secondaryFiles:
      - .tbi
  indels_recalibration:
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
  indels_tranches:
    type: File
    inputBinding:
      position: 7
      prefix: --tranches-file
  indel_filter_level:
    type: float?
    default: 95.0
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
  tmp_indel_recalibrated_vcf_filename:
    type: File
    outputBinding:
      glob: $(inputs.callset_name).$(inputs.idx).tmp.indel.recalibrated.vcf
    secondaryFiles:
      - .idx

stderr: $(inputs.callset_name).$(inputs.idx).tmp.indel.recalibrated.vcf.log

arguments:
  - position: 2
    valueFrom: ApplyVQSR
  - position: 3
    prefix: -O
    valueFrom: $(inputs.callset_name).$(inputs.idx).tmp.indel.recalibrated.vcf
  - position: 10
    prefix: -mode
    valueFrom: INDEL