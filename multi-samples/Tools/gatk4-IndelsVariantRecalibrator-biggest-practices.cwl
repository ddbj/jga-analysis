#!/usr/bin/env cwl-runner

class: CommandLineTool
id: gatk4-IndelsVariantRecalibrator-biggest-practices
label: gatk4-IndelsVariantRecalibrator-biggest-practices
cwlVersion: v1.1

requirements:
  DockerRequirement:
    dockerPull: us.gcr.io/broad-gatk/gatk:4.5.0.0
  ShellCommandRequirement: {}
  InlineJavascriptRequirement: {}
  
baseCommand: [gatk]

inputs:
  java_options:
    type: string?
    default: -Xms24000m -Xmx25000m
    inputBinding:
      position: 1
      prefix: --java-options
      shellQuote: true
  gvcf:
    type: File
    inputBinding:
      position: 3
      prefix: -V
    secondaryFiles:
      - .tbi
  recalibration_tranche_values:
    type:
      type: array
      items: float
      inputBinding:
        prefix: -tranche
    default: [100.0, 99.95, 99.9, 99.5, 99.0, 97.0, 96.0, 95.0, 94.0, 93.5, 93.0, 92.0, 91.0, 90.0]
    inputBinding:
      position: 7
  recalibration_annotation_values:
    type:
      type: array
      items: string
      inputBinding:
        prefix: -an
    default: ["FS", "ReadPosRankSum", "MQRankSum", "QD", "SOR"]
    inputBinding:
      position: 8
  max_gaussians:
    type: int
    default: 4
    inputBinding:
      position: 10
      prefix: --max-gaussians
  mills_resource_vcf:
    type: File
    inputBinding:
      position: 11
      prefix: -resource:mills,known=false,training=true,truth=true,prior=12
    secondaryFiles:
      - .tbi
  axiomPoly_resource_vcf:
    type: File
    inputBinding:
      position: 12
      prefix: -resource:axiomPoly,known=false,training=true,truth=false,prior=10
    secondaryFiles:
      - .tbi
  dbsnp_resource_vcf:
    type: File
    inputBinding:
      position: 13
      prefix: -resource:dbsnp,known=true,training=false,truth=false,prior=2
    secondaryFiles:
      - .idx

outputs:
  recalibration:
    type: File
    outputBinding:
      glob: gnarly_callset.indels.recal
    secondaryFiles:
      - .idx
  tranches:
    type: File
    outputBinding:
      glob: gnarly_callset.indels.tranches

stderr: gnarly_callset.indels.recal.log

arguments:
  - position: 2
    valueFrom: VariantRecalibrator
  - position: 4
    prefix: -O
    valueFrom: gnarly_callset.indels.recal
  - position: 5
    prefix: --tranches-file
    valueFrom: gnarly_callset.indels.tranches
  - position: 6
    valueFrom: --trust-all-polymorphic
  - position: 9
    prefix: -mode
    valueFrom: INDEL