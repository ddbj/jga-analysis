#!/usr/bin/env cwl-runner

class: CommandLineTool
id: tabix-bgzipped-vcf
label: tabix-bgzipped-vcf
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

requirements:
  DockerRequirement:
    dockerPull: ghcr.io/biosciencedbc/jga-analysis/fastq2cram-bqsr-haplotypecaller:1.0.0
  EnvVarRequirement:
    envDef:
      VCF_GZ: $(inputs.vcf_gz.path)
  InitialWorkDirRequirement:
    listing: [ $(inputs.vcf_gz) ]

baseCommand: [ bash, /tools/tabix.sh ]

inputs:
  vcf_gz:
    type: File
    format: edam:format_3016

outputs:
  indexed_vcf_gz:
    type: File
    format: edam:format_3016
    outputBinding:
      glob: $(inputs.vcf_gz.basename)
    secondaryFiles:
      - .tbi
  log:
    type: stderr

stderr: $(inputs.vcf_gz.basename).tbi.log
