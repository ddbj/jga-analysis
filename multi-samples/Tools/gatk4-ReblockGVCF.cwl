#!/usr/bin/env cwl-runner

class: CommandLineTool
id: gatk4-ReblockGVCF
label: gatk4-ReblockGVCF
cwlVersion: v1.1

requirements:
  DockerRequirement:
    dockerPull: us.gcr.io/broad-gatk/gatk:4.5.0.0
  ShellCommandRequirement: {}

baseCommand: java

inputs:
  java_options:
    type: string?
    default: -XX:-UseContainerSupport -Xms3g -Xmx3g
    inputBinding:
      position: 1
      shellQuote: false
  reference:
    type: File
    inputBinding:
      position: 4
      prefix: "-R"
    secondaryFiles:
      - .fai
      - ^.dict
  gvcf:
    type: File
    inputBinding:
      position: 5
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
      position: 8
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
    prefix: -jar
    valueFrom: /gatk/gatk-package-4.5.0.0-local.jar
  - position: 3
    valueFrom: ReblockGVCF
  - position: 6
    valueFrom: -do-qual-approx
  - position: 7
    valueFrom: --floor-blocks
  - position: 9
    prefix: "-O"
    valueFrom: $(inputs.outprefix).rb.g.vcf.gz
