#!/usr/bin/env cwl-runner

class: CommandLineTool
id: gatk4-MarkDuplicates
label: gatk4-MarkDuplicates
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

requirements:
  ShellCommandRequirement: {}

hints:
  DockerRequirement:
    dockerPull: ghcr.io/tafujino/jga-analysis/fastq2cram:latest

baseCommand: /usr/bin/java

inputs:
  reference:
    type: File
    format: edam:format_1929
    doc: FastA file for reference genome
    secondaryFiles:
      - .fai
      - ^.dict
    inputBinding:
      prefix: -R=
      separate: false
      position: 8
  cram:
    type: File
    format: edam:format_3462
    secondaryFiles:
      - .crai
    inputBinding:
      prefix: -I=
      separate: false
      position: 6
  interval_name:
    type: string
  interval_bed:
    type: File
    format: edam:format_3584
    inputBinding:
      prefix: -L=
      separate: false
      position: 5
  java_options:
    type: string?
    default: -XX:-UseContainerSupport -Xmx14g
    inputBinding:
      position: 1
      shellQuote: false
  num_threads:
    type: int
    default: 1
    inputBinding:
      prefix: --native-pair-hmm-threads=
      separate: false
      position: 9
  ploidy:
    type: int
    inputBinding:
      prefix: --sample-ploidy=
      separate: false
      position: 10

outputs:
  vcf:
    type: File
    format: edam:format_3016
    outputBinding:
      glob: $(inputs.cram.nameroot).$(inputs.interval_name).g.vcf
  log:
    type: stderr

stderr: $(inputs.cram.nameroot).$(inputs.interval_name).g.vcf.log

arguments:
  - position: 2
    prefix: -jar
    valueFrom: /tools/gatk-4.1.0.0/gatk-package-4.1.0.0-local.jar
  - position: 3
    valueFrom: HaplotypeCaller
  - position: 4
    prefix: -ERC
    valueFrom: GVCF
  - position: 7
    prefix: -O=
    separate: false
    valueFrom: $(inputs.cram.nameroot).$(inputs.interval_name).g.vcf
