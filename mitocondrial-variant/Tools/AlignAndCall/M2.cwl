#!/usr/bin/env cwl-runner

class: CommandLineTool
id: M2
label: M2
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

hints:
  - class: DockerRequirement
    dockerPull: broadinstitute/gatk:4.2.4.0

requirements:
  ShellCommandRequirement: {}

# NOTE:
#
# 1. In the original WDL implementation, there exists `make_bamout` input parameter.
#    If it is set to true, `--bam-output` option is enabled and BAM is produced by
#    Mutect2 command. Otherwise, an empty BAM is created.
#
#    In CWL implementation, BAM file is never created.
#
# 2. In the oritinal WDL implementation, VCF is compressed when input `compress_output_vcf`
#    is set to true.
#
#    In CWL implementation, VCF is not compressed.

baseCommand: [gatk]

inputs:
  java_options:
    type: string?
    inputBinding:
      position: 1
      prefix: --java-options
    default: -Xmx13500m
  reference:
    type: File
    format: edam:format_1929
    secondaryFiles:
      - .fai
      - ^.dict
    inputBinding:
      position: 3
      prefix: -R
  bam:
    type: File
    format: edam:format_2572
    secondaryFiles:
      - ^.bai
    inputBinding:
      position: 4
      prefix: -I
  m2_extra_args:
    type: string?
    inputBinding:
      position: 8
      shellQuote: false

outputs:
  raw_vcf:
    type: File
    format: edam:format_3016
    outputBinding:
      glob: $(inputs.bam.nameroot).vcf
    secondaryFiles:
      - .idx
  stats:
    type: File
    outputBinding:
      glob: $(inputs.bam.nameroot).vcf.stats
  log:
    type: stderr

stderr: $(inputs.bam.nameroot).vcf.log

arguments:
  - position: 2
    valueFrom: Mutect2
  - position: 5
    prefix: --read-filter
    valueFrom: MateOnSameContigOrNoMappedMateReadFilter
  - position: 6
    prefix: --read-filter
    valueFrom: MateUnmappedAndUnmappedReadFilter
  - position: 7
    prefix: -O
    valueFrom: $(inputs.bam.nameroot).vcf
  - position: 9
    prefix: --annotation
    valueFrom: StrandBiasBySample
  - position: 10
    valueFrom: --mitochondria-mode
  - position: 11
    prefix: --max-reads-per-alignment-start
    valueFrom: "75"
  - position: 12
    prefix: --max-mnp-distance
    valueFrom: "0"
