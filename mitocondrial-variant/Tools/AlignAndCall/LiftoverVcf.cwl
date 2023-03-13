#!/usr/bin/env cwl-runner

class: CommandLineTool
id: LiftoverVcf
label: LiftoverVcf
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

hints:
  - class: DockerRequirement
    dockerPull: us.gcr.io/broad-gotc-prod/genomes-in-the-cloud:2.4.2-1552931386

requirements:
  ShellCommandRequirement: {}

baseCommand: [java]

inputs:
  java_options:
    type: string?
    inputBinding:
      position: 1
      shellQuote: false
  shifted_vcf:
    type: File
    format: edam:format_3016
    inputBinding:
      position: 4
      prefix: I=
      separate: false
  reference:
    type: File
    format: edam:format_1929
    secondaryFiles:
      - .fai
      - ^.dict
    inputBinding:
      position: 6
      prefix: R=
      separate: false
  shift_back_chain:
    type: File
    format: edam:format_3982
    inputBinding:
      position: 7
      prefix: CHAIN=
      separate: false

outputs:
  shifted_back_vcf:
    type: File
    format: edam:format_3016
    outputBinding:
      glob: $(inputs.shifted_vcf.nameroot).shifted_back.vcf
  rejected_vcf:
    type: File
    format: edam:format_3016
    outputBinding:
      glob: $(inputs.shifted_vcf.nameroot).rejected.vcf
  log:
    type: stderr

stderr: $(inputs.shifted_vcf.nameroot).shifted_back.log

arguments:
  - position: 2
    prefix: -jar
    valueFrom: /usr/gitc/picard.jar
  - position: 3
    valueFrom: LiftoverVcf
  - position: 5
    prefix: O=
    separate: false
    valueFrom: $(inputs.shifted_vcf.nameroot).shifted_back.vcf
  - position: 8
    prefix: REJECT=
    separate: false
    valueFrom: $(inputs.shifted_vcf.nameroot).rejected.vcf
