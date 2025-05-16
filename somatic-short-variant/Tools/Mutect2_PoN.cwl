#!/usr/bin/env cwl-runner

class: CommandLineTool
id: mutect2_pon
label: mutect2_pon
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

hints:
  - class: DockerRequirement
    dockerPull: broadinstitute/gatk:4.2.4.0

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
  normal_cram:
    type: File
    format: edam:format_3462
    secondaryFiles:
      - .crai
    inputBinding:
      position: 4
      prefix: -I
  max-mnp-distance:
    doc: Note that as of May, 2019 -max-mnp-distance must be set to zero to avoid a bug in GenomicsDBImport.
    type: int?
    default: 0
    inputBinding:
      position: 5
      prefix: -max-mnp-distance
  outprefix:
    type: string

outputs:
  vcf_gz:
    type: File
    format: edam:format_3016
    outputBinding:
      glob: $(inputs.outprefix).normal.vcf.gz
    secondaryFiles:
      - .tbi
  log:
    type: stderr

arguments:
  - position: 2
    valueFrom: Mutect2
  - position: 6
    prefix: -O
    valueFrom: $(inputs.outprefix).normal.vcf.gz

stderr: $(inputs.outprefix).normal.vcf.log
