#!/usr/bin/env cwl-runner

class: CommandLineTool
id: tabix
label: tabix
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

requirements:
  InitialWorkDirRequirement:
    listing:
      - entry: $(inputs.vcf_gz)
        writable: true

hints:
  DockerRequirement:
    dockerPull: ghcr.io/tafujino/jga-analysis/fastq2cram_haplotypecaller:latest

baseCommand: [ tabix, -p, vcf ]

inputs:
  vcf_gz:
    type: File
    format: edam:format_3016
    inputBinding:
      position: 1

outputs:
  tabix:
    type: File
    format: edam:format_3616
    outputBinding:
      glob: $(inputs.vcf_gz.basename).tbi
  log:
    type: stderr

stderr: $(inputs.vcf_gz.basename).tbi.log
