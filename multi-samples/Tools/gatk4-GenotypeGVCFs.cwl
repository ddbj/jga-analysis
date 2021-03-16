#!/usr/bin/env cwl-runner

class: CommandLineTool
id: gatk4-GenotypeGVCFs
label: gatk4-GenotypeGVCFs
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
  
  dbsnp:
    type: File
    format: edam:format_3016
    doc: A dbSNP VCF file.
    secondaryFiles:
      - .idx
    inputBinding:
      prefix: -D
      position: 5

  genomicsDB:
    type: Directory
    doc: Genomics DB
    
  interval_bed:
    type: File
    format: edam:format_3584
    inputBinding:
      prefix: -L
      position: 10

  java_options:
    type: string?
    default: -XX:-UseContainerSupport -Xmx5g -Xms5g
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
      glob: $(inputs.outprefix).vcf
    secondaryFiles:
      - .idx
  log:
    type: stderr

stderr: $(inputs.outprefix).vcf.log

arguments:
  - position: 2
    prefix: -jar
    valueFrom: /gatk/gatk-package-4.2.0.0-local.jar
  - position: 3
    valueFrom: GenotypeGVCFs
  - position: 6
    prefix: --annotation-group
    valueFrom: StandardAnnotation
  - position: 7
    valueFrom: --only-output-calls-starting-in-intervals
  - position: 8
    valueFrom: --use-new-qual-calculator
  - position: 9
    prefix: -V
    valueFrom: gendb://$(inputs.genomicsDB.path)
  - position: 10
    prefix: -O
    valueFrom: $(inputs.outprefix).vcf

  
