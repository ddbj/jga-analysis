#!/usr/bin/env cwl-runner

class: CommandLineTool
id: Reblock
label: ReblockGVCF
cwlVersion: v1.2

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 3750 # WDL："3750 MiB"
    coresMin: 1
  DockerRequirement:
    dockerPull: us.gcr.io/broad-gatk/gatk:4.5.0.0

baseCommand: [gatk]

inputs:
  ref_fasta:
    type: File
    inputBinding:
      position: 3
      prefix: "-R"
    secondaryFiles:
      - .fai
      - ^.dict
  gvcf:
    type: File
    inputBinding:
      position: 4
      prefix: "-V"
    secondaryFiles:
      - .tbi

arguments:
  - position: 1
    prefix: --java-options
    valueFrom: "-Xms3000m -Xmx3000m"
  - position: 2
    valueFrom: ReblockGVCF
  - position: 5
    valueFrom: -do-qual-approx
  - position: 6
    valueFrom: --floor-blocks
  - position: 7
    prefix: -GQB
    valueFrom: "20"
  - position: 8
    prefix: -GQB
    valueFrom: "30"
  - position: 9
    prefix: -GQB
    valueFrom: "40"
  - position: 10
    prefix: "-O"
  #   valueFrom: "$(inputs.gvcf.basename).rb.g.vcf.gz"
    valueFrom: |
      ${
        var basename = inputs.gvcf.basename;
        var newBasename = basename.replace(/\.g\.vcf\.gz$/, '.rb.g.vcf.gz');
        return newBasename;
      }

outputs:
  output_vcf:
    type: File
    outputBinding:
      glob: "$(inputs.gvcf.basename).rb.g.vcf.gz"
  output_vcf_index:
    type: File
    outputBinding:
      glob: "$(inputs.gvcf.basename).rb.g.vcf.gz.tbi"
    