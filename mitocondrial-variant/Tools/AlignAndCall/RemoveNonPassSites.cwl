#!/usr/bin/env cwl-runner

class: CommandLineTool
id: RemoveNonPassSites
label: RemoveNonPassSites
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

hints:
  - class: DockerRequirement
    dockerPull: broadinstitute/gatk:4.2.4.0

baseCommand: [gatk]

inputs:
  in_vcf:
    type: File
    format: edam:format_3016
    inputBinding:
      position: 2
      prefix: -V

outputs:
  out_vcf:
    type: File
    format: edam:format_3016
    outputBinding:
      glob: $(inputs.in_vcf.nameroot).passOnly.vcf
  log:
    type: stderr

stderr: $(inputs.in_vcf.nameroot).passOnly.log

arguments:
  - position: 1
    valueFrom: SelectVariants
  - position: 3
    prefix: -O
    valueFrom: $(inputs.in_vcf.nameroot).passOnly.vcf
  - position: 4
    valueFrom: --exclude-filtered
