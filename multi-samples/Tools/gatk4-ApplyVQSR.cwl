#!/usr/bin/env cwl-runner

class: CommandLineTool
id: gatk4-ApplyVQSR
label: gatk4-ApplyVQSR
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

  recal_file:
    type: File
    doc: The input recal file used by ApplyVQSR
    secondaryFiles:
      - .idx
    inputBinding:
      prefix: --recal-file
      position: 5

  tranches_file:
    type: File
    inputBinding:
      prefix: --tranches-file
      position: 6
    doc: The input tranches file describing where to cut the data

  truth_sensitivity_filter_level:
    type: double
    default: 99.7
    inputBinding:
      prefix: --truth-sensitivity-filter-level
      position: 7
    doc: The truth sensitivity level at which to start filtering

  mode:
    type: string
    inputBinding:
      prefix: -mode
      position: 9
    doc: "Recalibration mode to employ: 1.) SNP for recalibrating only SNPs (emitting indels untouched in the output VCF); 2.) INDEL for indels; and 3.) BOTH for recalibrating both SNPs and indels simultaneously."
    
  java_options:
    type: string?
    default: -XX:-UseContainerSupport -Xmx24g -Xms24g
    inputBinding:
      position: 1
      shellQuote: false

  outprefix:
    type: string
  
outputs:
  vqsr_vcf:
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
    valueFrom: ApplyVQSR
  - position: 8
    prefix: --create-output-variant-index
    valueFrom: "true"
  - position: 10
    prefix: -O
    valueFrom: $(inputs.outprefix).vcf
  
  
