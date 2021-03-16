#!/usr/bin/env cwl-runner

class: CommandLineTool
id: bedops-vcf.gz2vcf
label: bedops-vcf.gz2vcf
cwlVersion: v1.1

$namespaces:
  edam: 'http://edamontology.org/'

requirements:
  DockerRequirement:
    dockerPull: biocontainers/bedops:v2.4.35dfsg-1-deb_cv1
  ShellCommandRequirement: {}
  
baseCommand: zcat

inputs:
  gz:
    type: File
    format: edam:format_3016
    doc: A VCF.GZ file containing variants
    inputBinding:
      position: 1

  outprefix:
    type: string
    
outputs:
  - id: out
    type: stdout
    format: edam:format_3016
  - id: log
    type: stderr

stderr: $(inputs.outprefix).vcf.log
stdout: $(inputs.outprefix).vcf
    
arguments: []

    
