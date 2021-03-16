#!/usr/bin/env cwl-runner

class: CommandLineTool
id: gatk4-VariantFiltration
label: gatk4-VariantFiltration
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

requirements:
  DockerRequirement:
    dockerPull: broadinstitute/gatk:4.2.0.0
  ShellCommandRequirement: {}
    
baseCommand: /usr/bin/java

inputs:
  vcf:
    type: File
    format: edam:format_3016
    doc: A VCF file containing variants
    secondaryFiles:
      - .idx
    inputBinding:
      prefix: -V
      position: 4

  excess_het_threshold:
    type: double
    default: 54.69
    doc: Threshold value for ExcessHet filter. ExcessHet is a phred-scaled p-value. Default value is 54.69, which means z-score=-4.5 or p-value=3.4e-06
      
  java_options:
    type: string?
    default: -XX:-UseContainerSupport -Xmx3g -Xms3g
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
    valueFrom: VariantFiltration
  - position: 5
    prefix: --filter-expression
    valueFrom: \"ExcessHet > $(inputs.excess_het_threshold)\"
    shellQuote: false
  - position: 6
    prefix: --filter-name
    valueFrom: ExcessHet
  - position: 7
    prefix: -O
    valueFrom: $(inputs.outprefix).vcf

  
