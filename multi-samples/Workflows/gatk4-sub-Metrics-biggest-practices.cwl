#!/usr/bin/env cwl-runner

class: Workflow
id: gatk4-sub-Metrics-biggest-practices
label: gatk4-sub-Metrics-biggest-practices
cwlVersion: v1.1

requirements:
  SubworkflowFeatureRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}

inputs:
  gatk4-CollectMetricsSharded_java_options:
    type: string?
  recalibrated_vcf_filename:
    type: File[]
    secondaryFiles:
      - .tbi
  dbsnp_vcf:
    type: File
    secondaryFiles:
      - .idx
  ref_dict:
    type: File
  THREAD_COUNT:
    type: int?
  targets_interval_list:
    type: File?
  callset_name:
    type: string
  idx:
    type: int[]
  # gatk4-xxx_java_options:
  #   type: string?

steps:
  gatk4-CollectMetricsSharded-biggest-practices:
    label: gatk4-CollectMetricsSharded-biggest-practices
    run: ../Tools/gatk4-CollectMetricsSharded-biggest-practices.cwl
    in:
      java_options: gatk4-CollectMetricsSharded_java_options
      input_vcf: recalibrated_vcf_filename
      dbsnp_vcf: dbsnp_vcf
      ref_dict: ref_dict
      THREAD_COUNT: THREAD_COUNT
      interval_list: targets_interval_list
      callset_name: callset_name
      idx: idx
    scatter:
      - input_vcf
      - idx
    scatterMethod: dotproduct
    out:
      - detail_metrics_file
      - summary_metrics_file
  # xyz:
  #   label: xyz
  #   run: ../Tools/xyz.cwl
  #   in:
  #     xxx: xxx
  #   out:
  #     - yyy

outputs:
  detail_metrics_file:
    type: File
    outputSource: gatk4-CollectMetricsSharded-biggest-practices/detail_metrics_file
  summary_metrics_file:
    type: File
    outputSource: gatk4-CollectMetricsSharded-biggest-practices/summary_metrics_file
  # indel_recalibration:
  #   type: File
  #   outputSource: gatk4-IndelsVariantRecalibrator-biggest-practices/recalibration
  #   secondaryFiles:
  #     - .idx