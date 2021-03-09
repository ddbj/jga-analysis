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
      position: 5

  bam:
    type: File
    format: edam:format_2572
    doc: A BAM file containing sequencing reads
    inputBinding:
      prefix: -I
      position: 6

  use_original_qualities:
    type: string
    doc: true or false
    default: "false"
    inputBinding:
      prefix: --use-original-qualities
      position: 7
      
  bqsr:
    type: File
    inputBinding:
      position: 8
      prefix: -bqsr
    doc: Input recalibration table for BQSR
    
  static_quantized_quals:
    type:
      type: array
      items: int
      inputBinding:
        prefix: --static-quantized-quals
    default: [10, 20, 30]
    inputBinding:
      position: 9
    doc: Use static quantized quality scores to a given number of levels (with -bqsr)

  outprefix:
    type: string

  java_options:
    type: string?
    default: -XX:-UseContainerSupport -Xmx3g -Xms3g
    inputBinding:
      position: 1
      shellQuote: false
    
outputs:
  out_bam:
    type: File
    format: edam:format_2572
    outputBinding:
      glob: $(inputs.outprefix).bam
    secondaryFiles:
      - ^.bai

  log:
    type: stderr

stderr: $(inputs.outprefix).bam.log

arguments:
  - position: 2
    prefix: -jar
    valueFrom: /gatk/gatk-package-4.2.0.0-local.jar
  - position: 3
    valueFrom: ApplyBQSR
  - position: 4
    valueFrom: --add-output-sam-program-record
  - position: 10
    prefix: -O
    valueFrom: $(inputs.outprefix).bam

  
