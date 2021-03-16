#!/usr/bin/env cwl-runner

class: CommandLineTool
id: gatk4-CreateSomaticPanelOfNormals
label: gatk4-CreateSomaticPanelOfNormals
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

requirements:
  DockerRequirement:
    dockerPull: broadinstitute/gatk:4.2.0.0
  ShellCommandRequirement: {}
    
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
      prefix: -R
      position: 4
  
  germline_resource:
    type: File
    format: edam:format_3016
    doc: Population vcf of germline sequencing containing allele fractions.
    secondaryFiles:
      - .tbi
    inputBinding:
      prefix: --germline-resource
      position: 5

  genomicsDB:
    type: Directory
    doc: Genomics DB
    
  java_options:
    type: string?
    default: -XX:-UseContainerSupport -Xmx7g -Xms7g
    inputBinding:
      position: 1
      shellQuote: false

  outprefix:
    type: string
  
outputs:
  vcf:
    type: File
    format: edam:format_3016
    outputBinding:
      glob: $(inputs.outprefix).vcf.gz
    secondaryFiles:
      - .tbi
  log:
    type: stderr

stderr: $(inputs.outprefix).vcf.gz.log

arguments:
  - position: 2
    prefix: -jar
    valueFrom: /gatk/gatk-package-4.2.0.0-local.jar
  - position: 3
    valueFrom: CreateSomaticPanelOfNormals
  - position: 6
    prefix: -V
    valueFrom: gendb://$(inputs.genomicsDB.path)
  - position: 7
    prefix: -O
    valueFrom: $(inputs.outprefix).vcf.gz

  
