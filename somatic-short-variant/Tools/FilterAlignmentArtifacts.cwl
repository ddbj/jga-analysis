#!/usr/bin/env cwl-runner

class: CommandLineTool
id: FilterAlignmentArtifacts
label: FilterAlignmentArtifacts
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
  tumor_cram:
    type: File
    format: edam:format_3462
    secondaryFiles:
      - .crai
    inputBinding:
      position: 5
      prefix: -I
  bwa_mem_index_image:
    type: File
    inputBinding:
      position: 6
      prefix: --bwa-mem-index-image
  extra_args:
    type: string?
    inputBinding:
      position: 8
      shellQuote: false
  outprefix:
    type: string

outputs:
  out_vcf_gz:
    type: File
    outputBinding:
      glob: $(inputs.outprefix).somatic.filter.aa.vcf.gz
    secondaryFiles:
      - .tbi
  log:
    type: stderr

arguments:
  - position: 2
    valueFrom: FilterAlignmentArtifacts
  - position: 7
    prefix: -O
    valueFrom: $(inputs.outprefix).somatic.filter.aa.vcf.gz

stderr: $(inputs.outprefix).somatic.filter.aa.log
