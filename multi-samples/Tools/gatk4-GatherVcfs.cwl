#!/usr/bin/env cwl-runner

class: CommandLineTool
id: picard-GatherVcfs
label: picard-GatherVcfs
cwlVersion: v1.1

$namespaces:
  edam: 'http://edamontology.org/'

requirements:
  DockerRequirement:
    dockerPull: broadinstitute/gatk:4.2.0.0
  ShellCommandRequirement: {}
  
baseCommand: java

inputs:
  vcfs:
    type:
      type: array
      items: File
      inputBinding:
        prefix: -I
    secondaryFiles:
      - .idx
    inputBinding:
      position: 4
    doc: VCF files to be gathered

  outprefix:
    type: string

  java_options:
    type: string?
    default: -XX:-UseContainerSupport -Xmx3g -Xms3g
    inputBinding:
      position: 1
      shellQuote: false
    
outputs:
  - id: gathered_vcf
    type: File
    format: edam:format_3016
    outputBinding:
      glob: $(inputs.outprefix).vcf
    secondaryFiles:
      - ^.idx
  - id: log
    type: stderr

stderr: $(inputs.outprefix).vcf.log
    
arguments:
  - position: 2
    prefix: -jar
    valueFrom: /gatk/gatk-package-4.2.0.0-local.jar
  - position: 3
    valueFrom: GatherVcfs
  - position: 5
    prefix: -O
    valueFrom: $(inputs.outprefix).vcf

    
