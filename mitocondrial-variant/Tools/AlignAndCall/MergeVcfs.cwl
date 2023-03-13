#!/usr/bin/env cwl-runner

class: CommandLineTool
id: MergeVcfs
label: MergeVcfs
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
  shifted_back_vcf:
    type: File
    format: edam:format_3016
    inputBinding:
      position: 4
      prefix: I=
      separate: false
  vcf:
    type: File
    format: edam:format_3016
    inputBinding:
      position: 5
      prefix: I=
      separate: false
  outprefix:
    type: string

outputs:
  merged_vcf:
    type: File
    format: edam:format_3016
    outputBinding:
      glob: $(inputs.outprefix).merged.vcf
    secondaryFiles:
      - .idx
  log:
    type: stderr

stderr: $(inputs.outprefix).merged.log

arguments:
  - position: 2
    prefix: -jar
    valueFrom: /usr/gitc/picard.jar
  - position: 3
    valueFrom: MergeVcfs
  - position: 6
    prefix: O=
    separate: false
    valueFrom: $(inputs.outprefix).merged.vcf
