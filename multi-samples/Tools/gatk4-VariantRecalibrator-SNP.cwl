#!/usr/bin/env cwl-runner

class: CommandLineTool
id: gatk4-VariantRecalibrator-SNP
label: gatk4-VarinatRecalibrator-SNP
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

requirements:
  DockerRequirement:
    dockerPull: broadinstitute/gatk:4.2.0.0
  ShellCommandRequirement: {}
    
baseCommand: /usr/bin/java

inputs:
  vcf:
    type: File
    format: edam:format_3016
    doc: A VCF file containing variants
    secondaryFiles:
      - .idx
    inputBinding:
      prefix: -V
      position: 4

  recalibration_tranche_values:
    type:
      type: array
      items: double
      inputBinding:
        prefix: -tranche
    default: [100.0, 99.95, 99.9, 99.8, 99.6, 99.5, 99.4, 99.3, 99.0, 98.0, 97.0, 90.0]
    inputBinding:
      position: 6
    doc: The levels of truth sensitivity at which to slice the data. (in percent, that is 1.0 for 1 percent)

  recalibration_annotation_values:
    type:
      type: array
      items: string
      inputBinding:
        prefix: -an
    default: [QD, MQRankSum, ReadPosRankSum, FS, MQ, SOR, DP]
    inputBinding:
      position: 7
    doc: The names of the annotations which should used for calculations

  max_gaussians:
    type: int
    default: 6
    inputBinding:
      prefix: --max-gaussians
      position: 9
    doc: Max number of Gaussians for the positive model
      
  java_options:
    type: string?
    default: -XX:-UseContainerSupport -Xmx24g -Xms24g
    inputBinding:
      position: 1
      shellQuote: false

  hapmap_resource_vcf:
    type: File
    format: edam:format_3016
    secondaryFiles:
      - .tbi
    inputBinding:
      position: 10
      prefix: --resource:hapmap,known=false,training=true,truth=true,prior=15
    doc: hapmap_3.3.hg38.vcf.gz

  omni_resource_vcf:
    type: File
    format: edam:format_3016
    secondaryFiles:
      - .tbi
    inputBinding:
      position: 11
      prefix: --resource:omni,known=false,training=true,truth=true,prior=12
    doc: 1000G_omni2.5.hg38.vcf.gz

  one_thousand_genomes_resource_vcf:
    type: File
    format: edam:format_3016
    secondaryFiles:
      - .tbi
    inputBinding:
      position: 12
      prefix: --resource:1000G,known=false,training=true,truth=false,prior=10
    doc: 1000G_phase1.snps.high_confidence.hg38.vcf.gz

  dbsnp_resource_vcf:
    type: File
    format: edam:format_3016
    secondaryFiles:
      - .idx
    inputBinding:
      position: 13
      prefix: --resource:dbsnp,known=true,training=false,truth=false,prior=7
    doc: Homo_sapiens_assembly38.dbsnp138.vcf
    
  outprefix:
    type: string
  
outputs:
  recal:
    type: File
    outputBinding:
      glob: $(inputs.outprefix).recal
    secondaryFiles:
      - .idx
  tranches:
    type: File
    outputBinding:
      glob: $(inputs.outprefix).tranches
  R:
    type: File
    outputBinding:
      glob: $(inputs.outprefix).plots.R
    secondaryFiles:
      - .pdf
  log:
    type: stderr

stderr: $(inputs.outprefix).vcf.log

arguments:
  - position: 2
    prefix: -jar
    valueFrom: /gatk/gatk-package-4.2.0.0-local.jar
  - position: 3
    valueFrom: VariantRecalibrator
  - position: 5
    valueFrom: --trust-all-polymorphic 
  - position: 8
    prefix: --mode
    valueFrom: SNP
  - position: 13
    prefix: -O
    valueFrom: $(inputs.outprefix).recal
  - position: 15
    prefix: --tranches-file
    valueFrom: $(inputs.outprefix).tranches
  - position: 16
    prefix: --rscript-file
    valueFrom: $(inputs.outprefix).plots.R

  
