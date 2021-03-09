#!/usr/bin/env cwl-runner

class: CommandLineTool
id: gatk4-BaseRecalibrator
label: gatk4-BaseRecalibrator
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

  bam:
    type: File
    format: edam:format_2572
    doc: A BAM file containing sequencing reads
    inputBinding:
      prefix: -I
      position: 5

  use_original_qualities:
    type: string
    doc: true or false
    default: "false"
    inputBinding:
      prefix: --use-original-qualities
      position: 6
      
  dbsnp:
    type: File
    format: edam:format_3016
    secondaryFiles:
      - .idx
    inputBinding:
      position: 7
      prefix: --known-sites
    doc: Homo_sapiens_assembly38.dbsnp138.vcf
    
  mills:
    type: File
    format: edam:format_3016
    secondaryFiles:
      - .tbi
    inputBinding:
      position: 8
      prefix: --known-sites
    doc: Mills_and_1000G_gold_standard.indels.hg38.vcf.gz

  known_indels:
    type: File
    format: edam:format_3016
    secondaryFiles:
      - .tbi
    inputBinding:
      position: 9
      prefix: --known-sites
    doc: Homo_sapiens_assembly38.known_indels.vcf.gz

  outprefix:
    type: string

  java_options:
    type: string?
    default: -XX:-UseContainerSupport -Xmx4g -Xms4g
    inputBinding:
      position: 1
      shellQuote: false
    
outputs:
  table:
    type: File
    outputBinding:
      glob: $(inputs.outprefix).recal_data.table

  log:
    type: stderr

stderr: $(inputs.outprefix).recal_data.table.log

arguments:
  - position: 2
    prefix: -jar
    valueFrom: /gatk/gatk-package-4.2.0.0-local.jar
  - position: 3
    valueFrom: BaseRecalibrator
  - position: 10
    prefix: -O
    valueFrom: $(inputs.outprefix).recal_data.table

  
