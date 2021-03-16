#!/usr/bin/env cwl-runner

class: CommandLineTool
id: bedops-vcf2bed
label: bedops-vcf2bed
cwlVersion: v1.1

$namespaces:
  edam: 'http://edamontology.org/'

requirements:
  DockerRequirement:
    dockerPull: biocontainers/bedops:v2.4.35dfsg-1-deb_cv1
  ShellCommandRequirement: {}
  
baseCommand: vcf2bed

inputs:
  vcf:
    type: File
    format: edam:format_3016
    doc: A VCF file containing variants
    inputBinding:
      position: 1
      prefix: <
      shellQuote: false

  outprefix:
    type: string
    
outputs:
  - id: bed
    type: stdout
    format: edam:format_3584
  - id: log
    type: stderr

stderr: $(inputs.outprefix).bed.log
stdout: $(inputs.outprefix).bed
    
arguments:
  - position: 2
    valueFrom: "|"
  - position: 3
    valueFrom: "cut"
  - position: 4
    prefix: -f
    valueFrom: "1-5"
  - position: 5
    valueFrom: "|"
  - position: 6
    valueFrom: "awk"
  - position: 7
    prefix: -v
    valueFrom: FS="\t"
    shellQuote: false
  - position: 8
    prefix: -v
    valueFrom: OFS="\t"
    shellQuote: false
  - position: 9
    valueFrom: '{ print $1, $2, $3, $4, $5, "+"; }'

    

    
