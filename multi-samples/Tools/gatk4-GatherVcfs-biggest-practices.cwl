#!/usr/bin/env cwl-runner

class: CommandLineTool
id: gatk4-GatherVcfs-biggest-practices
label: gatk4-GatherVcfs-biggest-practices
cwlVersion: v1.1

requirements:
  DockerRequirement:
    dockerPull: us.gcr.io/broad-gatk/gatk:4.5.0.0
  ShellCommandRequirement: {}
  InlineJavascriptRequirement: {}

baseCommand: [gatk]

inputs:
  java_options:
    type: string?
    default: -Xms6000m -Xmx6500m
    inputBinding:
      position: 1
      prefix: --java-options
      shellQuote: true
  input_vcfs:
    type:
      type: array
      items: File
      inputBinding:
        prefix: --input
    secondaryFiles:
      - .tbi
    inputBinding:
      position: 5
  callset_name:
    type: string
    doc: (ex) gnarly_callset

outputs:
  output_vcf:
    type: File
    outputBinding:
      glob: $(inputs.callset_name).sites_only.vcf.gz
    # secondaryFiles:
    #   - .tbi

stderr: $(inputs.callset_name).sites_only.vcf.gz.log

arguments:
  - position: 2
    valueFrom: GatherVcfsCloud
  - position: 3
    valueFrom: --ignore-safety-checks
  - position: 4
    valueFrom: --gather-type BLOCK
    shellQuote: false
  - position: 6
    prefix: "--output"
    valueFrom: $(inputs.callset_name).sites_only.vcf.gz