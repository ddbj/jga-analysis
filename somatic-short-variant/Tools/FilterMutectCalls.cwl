#!/usr/bin/env cwl-runner

class: CommandLineTool
id: FilterMutectCalls
label: FilterMutectCalls
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
  in_vcf_gz:
    type: File
    format: edam:format_3016
    secondaryFiles:
      - .tbi
    inputBinding:
      position: 4
      prefix: -V
  contamination_table:
    type: File
    inputBinding:
      position: 5
      prefix: --contamination-table
  tumor_segmentation:
    type: File
    inputBinding:
      position: 6
      prefix: --tumor-segmentation
  orientation_bias_artifact_priors:
    type: File
    inputBinding:
      position: 7
      prefix: --orientation-bias-artifact-priors
  stats:
    type: File
    inputBinding:
      position: 8
      prefix: --stats
  extra_args:
    type: string?
    inputBinding:
      position: 11
      shellQuote: false
  outprefix:
    type: string

outputs:
  out_vcf_gz:
    type: File
    format: edam:format_3016
    outputBinding:
      glob: $(inputs.outprefix).somatic.filter.vcf.gz
    secondaryFiles:
      - .tbi
  filtering_stats:
    type: File
    outputBinding:
      glob: $(inputs.outprefix).somatic.filter.stats
  log:
    type: stderr

arguments:
  - position: 2
    valueFrom: FilterMutectCalls
  - position: 9
    prefix: -O
    valueFrom: $(inputs.outprefix).somatic.filter.vcf.gz
  - position: 10
    prefix: --filtering-stats
    valueFrom: $(inputs.outprefix).somatic.filter.stats

stderr: $(inputs.outprefix).somatic.filter.log
