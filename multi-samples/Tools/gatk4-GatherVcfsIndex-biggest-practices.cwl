#!/usr/bin/env cwl-runner

class: CommandLineTool
id: gatk4-GatherVcfsIndex-biggest-practices
label: gatk4-GatherVcfsIndex-biggest-practices
cwlVersion: v1.1

requirements:
  DockerRequirement:
    dockerPull: us.gcr.io/broad-gatk/gatk:4.5.0.0
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - entry: $(inputs.input_vcf)

baseCommand: [tabix]

inputs:
  input_vcf:
    type: File
    inputBinding:
      position: 1

outputs:
  output_vcf:
    type: File
    outputBinding:
      glob: $(inputs.input_vcf.basename)
    secondaryFiles:
      - .tbi

stderr: $(inputs.input_vcf.basename).tbi.log
