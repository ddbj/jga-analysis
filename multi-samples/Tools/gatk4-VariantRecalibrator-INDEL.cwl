#!/usr/bin/env cwl-runner

class: CommandLineTool
id: gatk4-VariantRecalibrator-INDEL
label: gatk4-VarinatRecalibrator-INDEL
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
    default: [100.0, 99.95, 99.9, 99.5, 99.0, 97.0, 96.0, 95.0, 94.0, 93.5, 93.0, 92.0, 91.0, 90.0]
    inputBinding:
      position: 6
    doc: The levels of truth sensitivity at which to slice the data. (in percent, that is 1.0 for 1 percent)

  recalibration_annotation_values:
    type:
      type: array
      items: string
      inputBinding:
        prefix: -an
    default: [FS, ReadPosRankSum, MQRankSum, QD, SOR, DP]
    inputBinding:
      position: 7
    doc: The names of the annotations which should used for calculations

  max_gaussians:
    type: int
    default: 4
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

  mills_resource_vcf:
    type: File
    format: edam:format_3016
    secondaryFiles:
      - .tbi
    inputBinding:
      position: 10
      prefix: --resource:mills,known=false,training=true,truth=true,prior=12
    doc: Mills_and_1000G_gold_standard.indels.hg38.vcf.gz

  axiomPoly_resource_vcf: 
    type: File
    format: edam:format_3016
    secondaryFiles:
      - .tbi
    inputBinding:
      position: 11
      prefix: --resource:axiomPoly,known=false,training=true,truth=false,prior=10
    doc: Axiom_Exome_Plus.genotypes.all_populations.poly.hg38.vcf.gz

  dbsnp_resource_vcf:
    type: File
    format: edam:format_3016
    secondaryFiles:
      - .idx
    inputBinding:
      position: 12
      prefix: --resource:dbsnp,known=true,training=false,truth=false,prior=2
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
    valueFrom: INDEL
  - position: 13
    prefix: -O
    valueFrom: $(inputs.outprefix).recal
  - position: 14
    prefix: --tranches-file
    valueFrom: $(inputs.outprefix).tranches
  - position: 15
    prefix: --rscript-file
    valueFrom: $(inputs.outprefix).plots.R

  
