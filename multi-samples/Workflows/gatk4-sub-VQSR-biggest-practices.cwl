#!/usr/bin/env cwl-runner

class: Workflow
id: gatk4-sub-VQSR-biggest-practices
label: gatk4-sub-VQSR-biggest-practices
cwlVersion: v1.1

requirements:
  SubworkflowFeatureRequirement: {}
  StepInputExpressionRequirement: {}

inputs:
  gatk4-IndelsVariantRecalibrator_java_options:
    type: string?
  sites_only_variant_filtered_vcf:
    type: File
    secondaryFiles:
      - .tbi
  indel_recalibration_tranche_values:
    type: float[]?
  indel_recalibration_annotation_values:
    type: string[]?
  allele_specific_annotations:
    type: boolean?
  IndelsVariantRecalibrator_max_gaussians:
    type: int
  mills_resource_vcf:
    type: File
    secondaryFiles:
      - .tbi
  axiomPoly_resource_vcf:
    type: File
    secondaryFiles:
      - .tbi
  dbsnp_resource_vcf:
    type: File
    secondaryFiles:
      - .idx
  callset_name:
    type: string
  # gatk4-xxx_java_options:
  #   type: string?

steps:
  gatk4-IndelsVariantRecalibrator-biggest-practices:
    label: gatk4-IndelsVariantRecalibrator-biggest-practices
    run: ../Tools/gatk4-IndelsVariantRecalibrator-biggest-practices.cwl
    in:
      java_options: gatk4-IndelsVariantRecalibrator_java_options
      sites_only_variant_filtered_vcf: sites_only_variant_filtered_vcf
      recalibration_tranche_values: indel_recalibration_tranche_values
      recalibration_annotation_values: indel_recalibration_annotation_values
      allele_specific_annotations: allele_specific_annotations
      max_gaussians: IndelsVariantRecalibrator_max_gaussian
      mills_resource_vcf: mills_resource_vcf
      axiomPoly_resource_vcf: axiomPoly_resource_vcf
      dbsnp_resource_vcf: dbsnp_resource_vcf
      callset_name: callset_name
    out:
      - recalibration
      - tranches
  # xyz:
  #   label: xyz
  #   run: ../Tools/xyz.cwl
  #   in:
  #     xxx: xxx
  #   out:
  #     - yyy

outputs:
  recalibration:
    type: File
    outputSource: gatk4-IndelsVariantRecalibrator-biggest-practices/recalibration
    secondaryFiles:
      - .idx
  tranches:
    type: File
    outputSource: gatk4-IndelsVariantRecalibrator-biggest-practices/tranches
  # sites_only_vcf:
  #   type: File
  #   outputSource: gatk4-MakeSitesOnlyVcf-biggest-practices/sites_only_vcf
  #   secondaryFiles:
  #     - .tbi