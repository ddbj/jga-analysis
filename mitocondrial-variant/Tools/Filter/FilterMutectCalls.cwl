#!/usr/bin/env cwl-runner

class: CommandLineTool
id: FilterMutectCalls
label: FilterMutectCalls
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

hints:
  - class: DockerRequirement
    dockerPull: broadinstitute/gatk:4.2.4.0

requirements:
  ShellCommandRequirement: {}

baseCommand: [gatk]

inputs:
  java_options:
    type: string?
    inputBinding:
      position: 1
      prefix: --java-options
      shellQuote: true
    default: -Xmx2500m
  raw_vcf:
    type: File
    format: edam:format_3016
    secondaryFiles:
      - .idx
    inputBinding:
      position: 3
      prefix: -V
  raw_vcf_stats:
    type: File
    inputBinding:
      position: 6
      prefix: --stats
  reference:
    type: File
    format: edam:format_1929
    secondaryFiles:
      - .fai
      - ^.dict
    inputBinding:
      position: 4
      prefix: -R
  m2_extra_filtering_args:
    type: string?
    inputBinding:
      position: 7
      shellQuote: false
  max_alt_allele_count:
    type: int
    inputBinding:
      position: 8
      prefix: --max-alt-allele-count
  vaf_filter_threshold:
    type: float?
    inputBinding:
      position: 10
      prefix: --min-allele-fraction
  f_score_beta:
    type: float?
    inputBinding:
      position: 11
      prefix: --f-score-beta
  max_contamination:
    type: float?
    inputBinding:
      position: 12
      prefix: --contamination-estimate
  outprefix:
    type: string

outputs:
  filtered_vcf:
    type: File
    format: edam:format_3016
    outputBinding:
      glob: $(inputs.outprefix).vcf
    secondaryFiles:
      - .idx
  log:
    type: stderr

stderr: $(inputs.outprefix).log

arguments:
  - position: 2
    valueFrom: FilterMutectCalls
  - position: 5
    prefix: -O
    valueFrom: $(inputs.outprefix).vcf
  - position: 9
    valueFrom: --mitochondria-mode
