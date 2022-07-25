#!/usr/bin/env cwl-runner

class: CommandLineTool
id: Funcotator
label: Funcotator
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

hints:
  - class: DockerRequirement
    dockerPull: broadinstitute/gatk:4.2.6.1

requirements:
  ShellCommandRequirement: {}

baseCommand: [ gatk ]

inputs:
  java_options:
    type: string?
    inputBinding:
      position: 1
      prefix: --java-options
  reference:
    type: File
    format: edam:format_1929
    secondaryFiles:
      - .fai
      - ^.dict
    inputBinding:
      position: 3
      prefix: -R
  reference_version:
    type: string
    default: hg38
    inputBinding:
      position: 4
      prefix: --ref-version
  in_vcf_gz:
    type: File
    format: edam:format_3016
    secondaryFiles:
      - .tbi
    inputBinding:
      position: 5
      prefix: -V
  data_sources:
    type: Directory
    inputBinding:
      position: 6
      prefix: --data-sources-path
  interval_list:
    type: File?
    inputBinding:
      position: 7
      prefix: -L
  tumor_name:
    type: string
    default: Unknown
  normal_name:
    type: string
    default: Unknown
  sequencing_center:
    type: string
    default: Unknown
  sequence_source:
    doc: WGS or WXS for whole genome or whole exome sequencing, respectively
    type: string
    default: Unknown
  transcript_selection_mode:
    type: string?
    inputBinding:
      position: 12
      prefix: --transcript-selection-mode
  transcript_selection_list:
    type: File?
    inputBinding:
      position: 13
      prefix: --transcript-list
  annotation_defaults:
    type:
      type: array
      items: string
      inputBinding:
        prefix: --annotation-default
    default: []
    inputBinding:
      position: 14
  annotation_overrides:
    type:
      type: array
      items: string
      inputBinding:
        prefix: --annotation-override
    default: []
    inputBinding:
      position: 15
  excluded_fields:
    type:
      type: array
      items: string
      inputBinding:
        prefix: --exclude-field
    default: []
    inputBinding:
      position: 16
  filter_funcotations:
    doc: ignore/drop variants that have been filtered in the input
    type: boolean
    default: false
    inputBinding:
      position: 17
      prefix: --remove-filtered-variants
  extra_args:
    type: string?
    inputBinding:
      position: 20
      shellQuote: false
  outprefix:
    type: string

outputs:
  maf:
    type: File
    outputBinding:
      glob: $(inputs.outprefix).somatic.filter.annotated.maf
    secondaryFiles:
      - .idx
  log:
    type: stderr

arguments:
  - position: 2
    valueFrom: Funcotator
  - position: 8
    prefix: --annotation-default
    valueFrom: "normal_barcode:$(inputs.normal_name)"
  - position: 9
    prefix: --annotation-default
    valueFrom: "tumor_barcode:$(inputs.tumor_name)"
  - position: 10
    prefix: --annotation-default
    valueFrom: "Center:$(inputs.sequencing_center)"
  - position: 11
    prefix: --annotation-default
    valueFrom: "source:$(inputs.sequence_source)"
  - position: 18
    prefix: --output-file-format
    valueFrom: MAF
  - position: 19
    prefix: -O
    valueFrom: $(inputs.outprefix).somatic.filter.annotated.maf

stderr: $(inputs.outprefix).somatic.filter.annotated.log
