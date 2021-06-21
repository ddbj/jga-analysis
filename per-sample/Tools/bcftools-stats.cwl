#!/usr/bin/env cwl-runner

class: CommandLineTool
id: bcftools-stats
label: bcftools-stats
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

requirements:
  DockerRequirement:
    dockerPull: biocontainers/bcftools:v1.9-1-deb_cv1

baseCommand: [ bcftools, stats ]

inputs:
  vcf:
    type: File
    format: edam:format_3016
    inputBinding:
      position: 1

outputs:
  bcftools_stats:
    type: stdout
  log:
    type: stderr

stdout: $(inputs.vcf.basename).bcftools-stats
stderr: $(inputs.vcf.basename).bcftools-stats.log
