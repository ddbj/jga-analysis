#!/usr/bin/env cwl-runner

class: CommandLineTool
id: bgzip
label: bgzip
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

requirements:
  DockerRequirement:
    dockerPull: ghcr.io/ddbj/jga-analysis/fastq2cram-bqsr-haplotypecaller:1.0.0
  EnvVarRequirement:
    envDef:
      VCF: $(inputs.vcf.path)
      NUM_THREADS: $(inputs.num_threads)
  ResourceRequirement:
    ramMin: $(inputs.ram_min)
    coresMin: $(inputs.num_threads)

baseCommand: [ bash, /tools/bgzip.sh ]

inputs:
  vcf:
    type: File
    format: edam:format_3016
  num_threads:
    type: int
    default: 1
  ram_min:
    type: int
    default: 48000

outputs:
  vcf_gz:
    type: File
    format: edam:format_3016
    outputBinding:
      glob: $(inputs.vcf.basename).gz
  log:
    type: stderr

stderr: $(inputs.vcf.basename).gz.log
