#!/usr/bin/env cwl-runner

class: Workflow
id: vqsr
label: vqsr
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

requirements:
  - class: StepInputExpressionRequirement
  
inputs:
  reference_dict:
    type: File
    doc: DICT index for FastA file for reference genome

  interval_list:
    type: File
    doc: Target intervals to restrict analysis to.

  dbsnp:
    type: File
    format: edam:format_3016
    secondaryFiles:
      - .idx
    doc: Homo_sapiens_assembly38.dbsnp138.vcf

  mills:
    type: File
    format: edam:format_3016
    secondaryFiles:
      - .tbi
    doc: Mills_and_1000G_gold_standard.indels.hg38.vcf.gz

  axiom: 
    type: File
    format: edam:format_3016
    secondaryFiles:
      - .tbi
    doc: Axiom_Exome_Plus.genotypes.all_populations.poly.hg38.vcf.gz

  hapmap:
    type: File
    format: edam:format_3016
    secondaryFiles:
      - .tbi
    doc: hapmap_3.3.hg38.vcf.gz

  omni:
    type: File
    format: edam:format_3016
    secondaryFiles:
      - .tbi
    doc: 1000G_omni2.5.hg38.vcf.gz

  one_thousand_genomes:
    type: File
    format: edam:format_3016
    secondaryFiles:
      - .tbi
    doc: 1000G_phase1.snps.high_confidence.hg38.vcf.gz
    
  vcfs:
    type:
      type: array
      items: File
    doc: gVCF files to be imported
    secondaryFiles:
      - .idx

  outprefix:
    type: string

  indel_recalibration_tranche_values:
    type:
      type: array
      items: double
    default: [100.0, 99.95, 99.9, 99.5, 99.0, 97.0, 96.0, 95.0, 94.0, 93.5, 93.0, 92.0, 91.0, 90.0]
    doc: The levels of truth sensitivity at which to slice the data. (in percent, that is 1.0 for 1 percent)

  indel_recalibration_annotation_values:
    type:
      type: array
      items: string
    default: [FS, ReadPosRankSum, MQRankSum, QD, SOR, DP]
    doc: The names of the annotations which should used for calculations

  indel_max_gaussians:
    type: int
    default: 4
    doc: Max number of Gaussians for the positive model

  indel_truth_sensitivity_filter_level:
    type: double
    default: 99.7
    doc: The truth sensitivity level at which to start filtering
    
  snp_recalibration_tranche_values:
    type:
      type: array
      items: double
    default: [100.0, 99.95, 99.9, 99.8, 99.6, 99.5, 99.4, 99.3, 99.0, 98.0, 97.0, 90.0]
    doc: The levels of truth sensitivity at which to slice the data. (in percent, that is 1.0 for 1 percent)

  snp_recalibration_annotation_values:
    type:
      type: array
      items: string
    default: [QD, MQRankSum, ReadPosRankSum, FS, MQ, SOR, DP]
    doc: The names of the annotations which should used for calculations

  snp_max_gaussians:
    type: int
    default: 6
    doc: Max number of Gaussians for the positive model
    
  snp_truth_sensitivity_filter_level:
    type: double
    default: 99.7
    doc: The truth sensitivity level at which to start filtering
    
  gatk4-GatherVcfs_java_options:
    type: string?
    
  gatk4-VariantRecalibrator-INDEL_java_options:
    type: string?

  gatk4-VariantRecalibrator-SNP_java_options:
    type: string?

  gatk4-ApplyVQSR-INDEL_java_options:
    type: string?

  gatk4-ApplyVQSR-SNP_java_options:
    type: string?

  gatk4-CollectVariantCallingMetrics_java_options:
    type: string?
    
  gatk4-CollectVariantCallingMetrics_num_threads:
    type: int
    default: 1
    
steps:
  gatk4-GatherVcfs:
    label: gatk4-GatherVcfs
    doc: Gather multiple VCFs into one VCF
    run: ../Tools/gatk4-GatherVcfs.cwl
    in:
      vcfs: vcfs
      outprefix:
        source: outprefix
        valueFrom: $(inputs.outprefix).gatk4-GatherVcfs
      java_options: gatk4-GatherVcfs_java_options
    out:
      [gathered_vcf, log]


  gatk4-VariantRecalibrator-INDEL:
    label: gatk4-VariantRecalibrator-INDEL
    doc: Recalibrate variant quality for INDELs
    run: ../Tools/gatk4-VariantRecalibrator-INDEL.cwl
    in:
      vcf: gatk4-GatherVcfs/gathered_vcf
      recalibration_tranche_values: indel_recalibration_tranche_values
      recalibration_annotation_values: indel_recalibration_annotation_values
      max_gaussians: indel_max_gaussians
      java_options: gatk4-VariantRecalibrator-INDEL_java_options
      mills_resource_vcf: mills
      axiomPoly_resource_vcf: axiom
      dbsnp_resource_vcf: dbsnp
      outprefix:
        source: outprefix
        valueFrom: $(inputs.outprefix).gatk4-VariantRecalibrator-INDEL
    out:
      [recal, tranches, R, log]

  gatk4-VariantRecalibrator-SNP:
    label: gatk4-VariantRecalibrator-SNP
    doc: Recalibrate variant quality for SNPs
    run: ../Tools/gatk4-VariantRecalibrator-SNP.cwl
    in:
      vcf: gatk4-GatherVcfs/gathered_vcf
      recalibration_tranche_values: snp_recalibration_tranche_values
      recalibration_annotation_values: snp_recalibration_annotation_values
      max_gaussians: snp_max_gaussians
      java_options: gatk4-VariantRecalibrator-SNP_java_options
      hapmap_resource_vcf: hapmap
      omni_resource_vcf: omni
      one_thousand_genomes_resource_vcf: one_thousand_genomes
      dbsnp_resource_vcf: dbsnp
      outprefix:
        source: outprefix
        valueFrom: $(inputs.outprefix).gatk4-VariantRecalibrator-SNP
    out:
      [recal, tranches, R, log]

  gatk4-ApplyVQSR-INDEL:
    label: gatk4-ApplyVQSR-INDEL
    doc: Apply variant quality score recalibration for INDELs
    run: ../Tools/gatk4-ApplyVQSR.cwl
    in:
      vcf: gatk4-GatherVcfs/gathered_vcf
      recal_file: gatk4-VariantRecalibrator-INDEL/recal
      tranches_file: gatk4-VariantRecalibrator-INDEL/tranches
      truth_sensitivity_filter_level: indel_truth_sensitivity_filter_level
      mode:
        valueFrom: INDEL
      java_options: gatk4-ApplyVQSR-INDEL_java_options
      outprefix:
        source: outprefix
        valueFrom: $(inputs.outprefix).gatk4-ApplyVQSR-INDEL
    out:
      [vqsr_vcf, log]

  gatk4-ApplyVQSR-SNP:
    label: gatk4-ApplyVQSR-SNP
    doc: Apply variant quality score recalibration for SNPs
    run: ../Tools/gatk4-ApplyVQSR.cwl
    in:
      vcf: gatk4-ApplyVQSR-INDEL/vqsr_vcf
      recal_file: gatk4-VariantRecalibrator-SNP/recal
      tranches_file: gatk4-VariantRecalibrator-SNP/tranches
      truth_sensitivity_filter_level: snp_truth_sensitivity_filter_level
      mode:
        valueFrom: SNP
      java_options: gatk4-ApplyVQSR-SNP_java_options
      outprefix: outprefix
    out:
      [vqsr_vcf, log]

  gatk4-CollectVariantCallingMetrics:
    label: gatk4-CollectVariantCallingMetrics
    doc: Collect variant calling metrics
    run: ../Tools/gatk4-CollectVariantCallingMetrics.cwl
    in:
      vcf: gatk4-ApplyVQSR-SNP/vqsr_vcf
      dbsnp: dbsnp
      sequence_dictionary: reference_dict
      interval_list: interval_list
      java_options: gatk4-CollectVariantCallingMetrics_java_options
      num_threads: gatk4-CollectVariantCallingMetrics_num_threads
      outprefix: outprefix
    out:
      [variant_calling_detail_metrics, variant_calling_summary_metrics, log]
        
outputs:
  gather-vcfs_log:
    type: File
    outputSource: gatk4-GatherVcfs/log

  vqsr-INDEL_plot:
    type: File
    outputSource: gatk4-VariantRecalibrator-INDEL/R 
    
  vqsr-SNP_plot:
    type: File
    outputSource: gatk4-VariantRecalibrator-SNP/R 

  vqsr-SNP_tranches:
    type: File
    outputSource: gatk4-VariantRecalibrator-SNP/tranches
    
  filnal_vcf:
    type: File
    outputSource: gatk4-ApplyVQSR-SNP/vqsr_vcf

  summary_metrics:
    type: File
    outputSource: gatk4-CollectVariantCallingMetrics/variant_calling_summary_metrics
    
  detail_metrics:
    type: File
    outputSource: gatk4-CollectVariantCallingMetrics/variant_calling_detail_metrics
  
  vqsr-INDEL_log:
    type: File
    outputSource: gatk4-VariantRecalibrator-INDEL/log

  # vqsr-SNP_log:
  #   type: File
  #   outputSource: gatk4-VariantRecalibrator-SNP/log

  # apply-vqsr-INDEL_log:
  #   type: File
  #   outputSource: gatk4-ApplyVQSR-INDEL/log

  # apply-vqsr-SNP_log:
  #   type: File
  #   outputSource: gatk4-ApplyVQSR-SNP/log

  # metrics_log:
  #   type: File
  #   outputSource: gatk4-CollectVariantCallingMetrics/log
    
