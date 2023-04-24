#!/usr/bin/env cwl-runner

class: CommandLineTool
id: gatk4-Haplotypecaller
label: gatk4-Haplotypecaller
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

requirements:
  DockerRequirement:
    dockerPull: ghcr.io/ddbj/jga-analysis/fastq2cram-bqsr-haplotypecaller:1.0.0
  ShellCommandRequirement: {}
  ResourceRequirement:
    coresMin: $(inputs.num_threads)
    ramMin: $(inputs.ram_min)

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
  sample_name:
    type: string
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
  ram_min:
    type: int
    default: 48000

outputs:
  vcf:
    type: File
    format: edam:format_3016
    outputBinding:
      glob: $(inputs.sample_name).$(inputs.interval_name).g.vcf
  log:
    type: stderr

stderr: $(inputs.sample_name).$(inputs.interval_name).g.vcf.log

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
    valueFrom: $(inputs.sample_name).$(inputs.interval_name).g.vcf
