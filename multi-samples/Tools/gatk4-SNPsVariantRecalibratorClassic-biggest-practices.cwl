#!/usr/bin/env cwl-runner

class: CommandLineTool
id: gatk4-SNPsVariantRecalibratorClassic-biggest-practices
label: gatk4-SNPsVariantRecalibratorClassic-biggest-practices
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
  sites_only_variant_filtered_vcf:
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
    default: [100.0, 99.95, 99.9, 99.8, 99.7, 99.6, 99.5, 99.4, 99.3, 99.0, 98.0, 97.0, 90.0]
    inputBinding:
      position: 7
  recalibration_annotation_values:
    type:
      type: array
      items: string
      inputBinding:
        prefix: -an
    default: ["QD", "MQRankSum", "ReadPosRankSum", "FS", "SOR"]
    inputBinding:
      position: 8
  allele_specific_annotations:
    type: boolean
    default: false
    inputBinding:
      position: 9
      prefix: --use-allele-specific-annotations
  model_report:
    type: File?
    inputBinding:
      position: 11
      valueFrom: |
        ${
          if (self) {
            return "--input-model " + self.path + " --output-tranches-for-scatter";
          } else {
            return null;
          }
        }
  max_gaussians:
    type: int
    default: 6
    inputBinding:
      position: 12
      prefix: --max-gaussians
  hapmap_resource_vcf:
    type: File
    inputBinding:
      position: 13
      prefix: -resource:hapmap,known=false,training=true,truth=true,prior=15
    secondaryFiles:
      - .tbi
  omni_resource_vcf:
    type: File
    inputBinding:
      position: 14
      prefix: -resource:omni,known=false,training=true,truth=true,prior=12
    secondaryFiles:
      - .tbi
  one_thousand_genomes_resource_vcf:
    type: File
    inputBinding:
      position: 15
      prefix: -resource:1000G,known=false,training=true,truth=false,prior=10
    secondaryFiles:
      - .tbi
  dbsnp_resource_vcf:
    type: File
    inputBinding:
      position: 16
      prefix: -resource:dbsnp,known=true,training=false,truth=false,prior=7
    secondaryFiles:
      - .idx
  callset_name:
    type: string
    doc: (ex) gnarly_callset

outputs:
  recalibration:
    type: File
    outputBinding:
      glob: $(inputs.callset_name).snps.recal
    secondaryFiles:
      - .idx
  tranches:
    type: File
    outputBinding:
      glob: $(inputs.callset_name).snps.tranches

stderr: $(inputs.callset_name).snps.recal.log

arguments:
  - position: 2
    valueFrom: VariantRecalibrator
  - position: 4
    prefix: -O
    valueFrom: $(inputs.callset_name).snps.recal
  - position: 5
    prefix: --tranches-file
    valueFrom: $(inputs.callset_name).snps.tranches
  - position: 6
    valueFrom: --trust-all-polymorphic
  - position: 10
    prefix: -mode
    valueFrom: SNP
