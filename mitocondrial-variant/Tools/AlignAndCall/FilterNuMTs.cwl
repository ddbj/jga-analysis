#!/usr/bin/env cwl-runner

class: CommandLineTool
id: FilterNuMTs
label: FilterNuMTs
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

hints:
  - class: DockerRequirement
    dockerPull: broadinstitute/gatk:4.2.4.0

baseCommand: [gatk]

inputs:
  reference:
    type: File
    format: edam:format_1929
    secondaryFiles:
      - .fai
      - ^.dict
    inputBinding:
      position: 2
      prefix: -R
  in_vcf:
    type: File
    format: edam:format_3016
    inputBinding:
      position: 3
      prefix: -V
  # In the original WDL implementation, `autosomal_coverage` is optional.
  # However, if the parameter is blank, a wrong command line is generated.
  # In our CWL implementation, `autosomal_coverage` is mandatory.
  autosomal_coverage:
    type: float
    inputBinding:
      position: 5
      prefix: --autosomal-coverage
  outprefix:
    type: string

outputs:
  out_vcf:
    type: File
    format: edam:format_3016
    outputBinding:
      glob: $(inputs.outprefix).vcf
  log:
    type: stderr

stderr: $(inputs.outprefix).log

arguments:
  - position: 1
    valueFrom: NuMTFilterTool
  - position: 4
    prefix: -O
    valueFrom: $(inputs.outprefix).vcf
