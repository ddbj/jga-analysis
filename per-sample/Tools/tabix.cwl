#!/usr/bin/env cwl-runner

class: CommandLineTool
id: tabix
label: tabix
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

requirements:
  DockerRequirement:
    dockerPull: ghcr.io/tafujino/jga-analysis/fastq2cram-bqsr-haplotypecaller:latest
  EnvVarRequirement:
    envDef:
      VCF_GZ: $(inputs.vcf_gz.path)

baseCommand: [ bash, /tools/tabix.sh ]

inputs:
  vcf_gz:
    type: File
    format: edam:format_3016

outputs:
  tbi:
    type: File
    format: edam:format_3616
    outputBinding:
      glob: $(inputs.vcf_gz.basename).tbi
  log:
    type: stderr

stderr: $(inputs.vcf_gz.basename).tbi.log
