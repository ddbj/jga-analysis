#!/usr/bin/env cwl-runner

class: CommandLineTool
id: GetPileupSummaries
label: GetPileupSummaries
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

hints:
  - class: DockerRequirement
    dockerPull: broadinstitute/gatk:4.2.6.1

requirements:
  ShellCommandRequirement: {}
  InlineJavascriptRequirement: {}

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
  cram:
    type: File
    format: edam:format_3462
    secondaryFiles:
      - .crai
    inputBinding:
      position: 4
      prefix: -I
  is_tumor:
    type: boolean
    doc: If the sample is tumor -> true, normal -> false
  interval_list:
    type: File?
    inputBinding:
      position: 5
      prefix: -L
  variants_for_contamination:
    doc: e.g. small_exac_common_3.hg38.vcf.gz
    type: File
    format: edam:format_3016
    secondaryFiles:
      - .tbi
  extra_args:
    type: string?
    inputBinding:
      position: 9
      shellQuote: false
  outprefix:
    type: string

outputs:
  pileups:
    type: File
    outputBinding:
      glob: |
        $(inputs.outprefix).somatic.$(inputs.is_tumor ? "tumor" : "normal")-pileups.table
  log:
    type: stderr

arguments:
  - position: 2
    valueFrom: GetPileupSummaries
  - position: 5
    prefix: --interval-set-rule
    valueFrom: INTERSECTION
  - position: 6
    prefix: -V
    valueFrom: $(inputs.variants_for_contamination)
  - position: 7
    prefix: -L
    valueFrom: $(inputs.variants_for_contamination)
  - position: 8
    prefix: -O
    valueFrom: |
      $(inputs.outprefix).somatic.$(inputs.is_tumor ? "tumor" : "normal")-pileups.table

stderr: |
  $(inputs.outprefix).somatic.$(inputs.is_tumor ? "tumor" : "normal")-pileups.table.log
