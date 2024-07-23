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
    type: int?
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
  gatk4-SNPsVariantRecalibratorClassic_java_options:
    type: string?
  snp_recalibration_tranche_values:
    type: float[]?
  snp_recalibration_annotation_values:
    type: string[]?
  model_report:
    type: File?
  SNPsVariantRecalibratorClassic_max_gaussians:
    type: int?
  hapmap_resource_vcf:
    type: File
    secondaryFiles:
      - .tbi
  omni_resource_vcf:
    type: File
    secondaryFiles:
      - .tbi
  one_thousand_genomes_resource_vcf:
    type: File
    secondaryFiles:
      - .tbi
  # gatk4-ApplyRecalibration-INDEL_java_options:
  #   type: string?
  # variant_filtered_vcf:
  #   type: File
  #   secondaryFiles:
  #     - .tbi
  # vqsr_indel_filter_level:
  #   type: float?
  # create-output-variant-index:
  #   type: string?
  # idx:
  #   type: int
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
      max_gaussians: IndelsVariantRecalibrator_max_gaussians
      mills_resource_vcf: mills_resource_vcf
      axiomPoly_resource_vcf: axiomPoly_resource_vcf
      dbsnp_resource_vcf: dbsnp_resource_vcf
      callset_name: callset_name
    out:
      - recalibration
      - tranches
  gatk4-SNPsVariantRecalibratorClassic-biggest-practices:
    label: gatk4-SNPsVariantRecalibratorClassic-biggest-practices
    run: ../Tools/gatk4-SNPsVariantRecalibratorClassic-biggest-practices.cwl
    in:
      java_options: gatk4-SNPsVariantRecalibratorClassic_java_options
      sites_only_variant_filtered_vcf: sites_only_variant_filtered_vcf
      recalibration_tranche_values: snp_recalibration_tranche_values
      recalibration_annotation_values: snp_recalibration_annotation_values
      allele_specific_annotations: allele_specific_annotations
      model_report: model_report
      max_gaussians: SNPsVariantRecalibratorClassic_max_gaussians
      hapmap_resource_vcf: hapmap_resource_vcf
      omni_resource_vcf: omni_resource_vcf
      one_thousand_genomes_resource_vcf: one_thousand_genomes_resource_vcf
      dbsnp_resource_vcf: dbsnp_resource_vcf
      callset_name: callset_name
    out:
      - recalibration
      - tranches
  # gatk4-ApplyRecalibration-INDEL-biggest-practices:
  #   label: gatk4-ApplyRecalibration-INDEL-biggest-practices
  #   run: ../Tools/gatk4-ApplyRecalibration-INDEL-biggest-practices.cwl
  #   in:
  #     java_options: gatk4-ApplyRecalibration-INDEL_java_options
  #     input_vcf: variant_filtered_vcf
  #     indels_recalibration: gatk4-IndelsVariantRecalibrator-biggest-practices/recalibration
  #     allele_specific_annotations: allele_specific_annotations
  #     indels_tranches: gatk4-IndelsVariantRecalibrator-biggest-practices/tranches
  #     indel_filter_level: vqsr_indel_filter_level
  #     create-output-variant-index: create-output-variant-index
  #     callset_name: callset_name
  #     idx: idx
  #   out:
  #     - tmp_indel_recalibrated_vcf_filename
  # xyz:
  #   label: xyz
  #   run: ../Tools/xyz.cwl
  #   in:
  #     xxx: xxx
  #   out:
  #     - yyy

outputs:
  indel_recalibration:
    type: File
    outputSource: gatk4-IndelsVariantRecalibrator-biggest-practices/recalibration
    secondaryFiles:
      - .idx
  indel_tranches:
    type: File
    outputSource: gatk4-IndelsVariantRecalibrator-biggest-practices/tranches
  snp_recalibration:
    type: File
    outputSource: gatk4-SNPsVariantRecalibratorClassic-biggest-practices/recalibration
    secondaryFiles:
      - .idx
  snp_tranches:
    type: File
    outputSource: gatk4-SNPsVariantRecalibratorClassic-biggest-practices/tranches
  # tmp_indel_recalibrated_vcf_filename:
  #   type: File
  #   outputSource: gatk4-ApplyRecalibration-INDEL-biggest-practices/tmp_indel_recalibrated_vcf_filename
  #   secondaryFiles:
  #     - .idx
  # sites_only_vcf:
  #   type: File
  #   outputSource: gatk4-MakeSitesOnlyVcf-biggest-practices/sites_only_vcf
  #   secondaryFiles:
  #     - .tbi