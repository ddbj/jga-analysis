#!/usr/bin/env cwl-runner

class: CommandLineTool
id: gatk4-Mutect2-tumor-only-mode
label: gatk4-Mutect2-tumor-only-mode
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

  cram:
    type: File
    format: edam:format_3462
    doc: A CRAM file containing sequencing reads
    inputBinding:
      prefix: -I
      position: 5
    secondaryFiles:
      - .crai

  interval_bed:
    type: File
    format: edam:format_3584
    inputBinding:
      prefix: -L
      position: 6

  max_mnp_distance:
    type: int
    doc: Two or more phased substitutions separated by this distance or less are merged into MNPs.
    default: 1
    inputBinding:
      prefix: --max-mnp-distance
      position: 7
      
  outprefix:
    type: string

  java_options:
    type: string?
    default: -XX:-UseContainerSupport -Xmx32g -Xms32g
    inputBinding:
      position: 1
      shellQuote: false

  num_threads:
    type: int
    default: 1
    doc: How many threads should a native pairHMM implementation use
    inputBinding:
      prefix: --native-pair-hmm-threads
      position: 8
      
outputs:
  vcf:
    type: File
    outputBinding:
      glob: $(inputs.outprefix).vcf.gz
    secondaryFiles:
      - .tbi
      - .stats

  log:
    type: stderr

stderr: $(inputs.outprefix).vcf.gz.log

arguments:
  - position: 2
    prefix: -jar
    valueFrom: /gatk/gatk-package-4.2.0.0-local.jar
  - position: 3
    valueFrom: Mutect2
  - position: 9
    prefix: -O
    valueFrom: $(inputs.outprefix).vcf.gz

  
