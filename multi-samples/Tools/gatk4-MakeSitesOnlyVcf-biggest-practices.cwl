#!/usr/bin/env cwl-runner

class: CommandLineTool
id: gatk4-MakeSitesOnlyVcf-biggest-practices
label: gatk4-MakeSitesOnlyVcf-biggest-practices
cwlVersion: v1.1

requirements:
  DockerRequirement:
    dockerPull: us.gcr.io/broad-gatk/gatk:4.5.0.0
  ShellCommandRequirement: {}

baseCommand: [gatk]

inputs:
  java_options:
    type: string?
    default: -Xms3000m -Xmx3250m
    inputBinding:
      position: 1
      prefix: --java-options
      shellQuote: true
  variant_filtered_vcf_filename:
    type: File
    inputBinding:
      position: 3
      prefix: "-I"
    secondaryFiles:
      - .tbi
  callset_name:
    type: string
    doc: (ex) gnarly_callset
  idx:
    type: int
    doc: unpadded_intervals, row number

outputs:
  sites_only_vcf:
    type: File
    outputBinding:
      glob: $(inputs.callset_name).$(inputs.idx).sites_only.variant_filtered.vcf.gz
    secondaryFiles:
      - .tbi

stderr: $(inputs.callset_name).$(inputs.idx).sites_only.variant_filtered.vcf.gz.log

arguments:
  - position: 2
    valueFrom: MakeSitesOnlyVcf
  - position: 4
    prefix: "-O"
    valueFrom: $(inputs.callset_name).$(inputs.idx).sites_only.variant_filtered.vcf.gz