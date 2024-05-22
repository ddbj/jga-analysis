#!/usr/bin/env cwl-runner

class: CommandLineTool
id: gatk4-Reblock
label: gatk4-Reblock
cwlVersion: v1.1

requirements:
  InlineJavascriptRequirement: {}
  DockerRequirement:
    dockerPull: us.gcr.io/broad-gatk/gatk:4.5.0.0
  ShellCommandRequirement: {}

# baseCommand: [gatk]
baseCommand: java

inputs:
  ref_fasta:
    type: File
    inputBinding:
      position: 4
      prefix: "-R"
    secondaryFiles:
      - .fai
      - ^.dict
  gvcf:
    type: File
    inputBinding:
      position: 5
      prefix: "-V"
    secondaryFiles:
      - .tbi
  java_options:
    type: string?
    default: -XX:-UseContainerSupport -Xms3g -Xmx3g
    inputBinding:
      position: 1
      shellQuote: false
  gq_bands:
    type:
      type: array
      items: int
      inputBinding:
        prefix: -GQB
    default: [20, 30, 40]
    inputBinding:
      position: 8

arguments:
  # - position: 1
  #   prefix: --java-options
  #   valueFrom: "-Xms3000m -Xmx3000m"
  - position: 2
    prefix: -jar
    valueFrom: /gatk/gatk-package-4.5.0.0-local.jar
  - position: 3
    valueFrom: ReblockGVCF
  - position: 6
    valueFrom: -do-qual-approx
  - position: 7
    valueFrom: --floor-blocks
  # - position: 8
  #   prefix: -GQB
  #   valueFrom: "20"
  # - position: 9
  #   prefix: -GQB
  #   valueFrom: "30"
  # - position: 10
  #   prefix: -GQB
  #   valueFrom: "40"
  - position: 9
    prefix: "-O"
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
      glob: |
        ${
          var basename = inputs.gvcf.basename;
          var newBasename = basename.replace(/\.g\.vcf\.gz$/, '.rb.g.vcf.gz');
          return newBasename;
        }
  output_vcf_index:
    type: File
    outputBinding:
      glob: |
        ${
          var basename = inputs.gvcf.basename;
          var newBasename = basename.replace(/\.g\.vcf\.gz$/, '.rb.g.vcf.gz.tbi');
          return newBasename;
        }