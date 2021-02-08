#!/usr/bin/env cwl-runner

class: CommandLineTool
id: bgzip
label: bgzip
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

requirements:
  DockerRequirement:
    dockerPull: ghcr.io/tafujino/jga-analysis/fastq2cram_haplotypecaller:latest
  InitialWorkDirRequirement:
    listing:
      - entry: $(inputs.vcf)
        writable: true

baseCommand: bgzip

inputs:
  vcf:
    type: File
    format: edam:format_3016
    inputBinding:
      position: 2
  num_threads:
    type: int
    default: 1
    inputBinding:
      prefix: -@
      position: 1

outputs:
  vcf_gz:
    type: File
    format: edam:format_3016
    outputBinding:
      glob: $(inputs.vcf.basename).gz
  log:
    type: stderr

stderr: $(inputs.vcf.basename).gz.log
