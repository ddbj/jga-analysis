#!/usr/bin/env cwl-runner

class: CommandLineTool
id: bcftools-index-t
label: bcftools-index-t
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

requirements:
  DockerRequirement:
    dockerPull: biocontainers/bcftools:v1.9-1-deb_cv1
    
baseCommand: [ bcftools, index, -t ]

inputs:
  vcf:
    type: File
    doc: A VCF file containing variants
    inputBinding:
      position: 1

outputs:
  - id: tbi
    type: File
    outputBinding:
      glob: $(inputs.vcf.basename).tbi

arguments:
  - position: 2
    prefix: -o 
    valueFrom: $(inputs.vcf.basename).tbi


