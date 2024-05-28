#!/usr/bin/env cwl-runner

class: CommandLineTool
id: gatk4-ReblockGVCF
label: gatk4-ReblockGVCF
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
    default: -Xms3000m -Xmx3000m
    inputBinding:
      position: 1
      shellQuote: true
  reference:
    type: File
    inputBinding:
      position: 3
      prefix: "-R"
    secondaryFiles:
      - .fai
      - ^.dict
  gvcf:
    type: File
    inputBinding:
      position: 4
      prefix: "-V"
    secondaryFiles:
      - .tbi
  gq_bands:
    type:
      type: array
      items: int
      inputBinding:
        prefix: -GQB
    default: [20, 30, 40]
    inputBinding:
      position: 7
  annotations_to_keep_command:
    type: 
      - "null"
      - type: array
        items: string
        inputBinding:
          prefix: --annotations-to-keep
    inputBinding:
      position: 8
  annotations_to_remove_command:
    type:
      - "null"
      - type: array
        items: string
        inputBinding:
          prefix: --format-annotations-to-remove
    inputBinding:
      position: 9
  tree_score_cutoff:  
    type: float?
    inputBinding:
      position: 10
      prefix: "--tree-score-threshold-to-no-call"
  move_filters_to_genotypes:
    type: boolean
    default: false
    inputBinding:
      position: 11
      prefix: --add-site-filters-to-genotype
  outprefix:
    type: string
    
outputs:
  rb_gvcf:
    type: File
    outputBinding:
      glob: $(inputs.outprefix).rb.g.vcf.gz
    secondaryFiles:
      - .tbi

stderr: $(inputs.outprefix).rb.g.vcf.gz.log

arguments:
  - position: 2
    valueFrom: ReblockGVCF
  - position: 5
    valueFrom: -do-qual-approx
  - position: 6
    valueFrom: --floor-blocks
  - position: 12
    prefix: "-O"
    valueFrom: $(inputs.outprefix).rb.g.vcf.gz
