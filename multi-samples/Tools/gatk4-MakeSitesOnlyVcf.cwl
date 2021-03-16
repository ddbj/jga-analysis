#!/usr/bin/env cwl-runner

class: CommandLineTool
id: gatk4-MakeSitesOnlyVcf
label: gatk4-MakeSitesOnlyVcf
cwlVersion: v1.1

$namespaces:
  edam: 'http://edamontology.org/'

requirements:
  DockerRequirement:
    dockerPull: broadinstitute/gatk:4.2.0.0
  ShellCommandRequirement: {}
  
baseCommand: java

inputs:
  vcf:
    type: File
    format: edam:format_3016
    doc: A VCF file containing variants
    secondaryFiles:
      - .idx
    inputBinding:
      prefix: -INPUT
      position: 4

  outprefix:
    type: string

  java_options:
    type: string?
    default: -XX:-UseContainerSupport -Xmx3g -Xms3g
    inputBinding:
      position: 1
      shellQuote: false


    
outputs:
  - id: sites_only_vcf
    type: File
    format: edam:format_3016
    outputBinding:
      glob: $(inputs.outprefix).vcf
    secondaryFiles:
      - .idx
  - id: log
    type: stderr

stderr: $(inputs.outprefix).vcf.log
    
arguments:
  - position: 2
    prefix: -jar
    valueFrom: /gatk/gatk-package-4.2.0.0-local.jar
  - position: 3
    valueFrom: MakeSitesOnlyVcf
  - position: 5
    prefix: -OUTPUT
    valueFrom: $(inputs.outprefix).vcf

    
