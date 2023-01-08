#!/usr/bin/env cwl-runner

class: Workflow
id: multisamples
label: multisamples
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

requirements:
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  SubworkflowFeatureRequirement: {}
  ScatterFeatureRequirement: {}
  StepInputExpressionRequirement: {}
  ResourceRequirement:
    outdirMin: 40960
    tmpdirMin: 65536
    ramMin: 65536
    coresMin: 8
inputs:
  sample_set:
    type: string
  interval_type:
    type: string
  
  reference:
    type: File
    format: edam:format_1929
    doc: FastA file for reference genome
    secondaryFiles:
      - .fai
      - ^.dict


  dbsnp:
    type: File
    format: edam:format_3016
    doc: A dbSNP VCF file.
    secondaryFiles:
      - .idx

  gvcfs:
    type:
      type: array
      items: File
    doc: gVCF files to be imported
    secondaryFiles:
      - .tbi

  interval_bed_list:
    type:
      type: array
      items:
        - type: record
          fields:

            interval_bed:
              type: File
              format: edam:format_3584


  genomicsDB_batch_size:
    type: int
    default: 0




  genomicsDB_interval_padding:
    type: int
    default: 0
    
  gatk4-GenomicsDBImport_java_options:
    type: string?
    
  gatk4-GenomicsDBImport_num_threads:
    type: int
    default: 1

  gatk4-GenotypeGVCFs_java_options:
    type: string?

  gatk4-VariantFiltration_java_options:
    type: string?

  gatk4-MakeSitesOnlyVcf_java_options:
    type: string?

##
  reference_dict:
    type: File
    doc: DICT index for FastA file for reference genome

  interval_list:
    type: File
    doc: Target intervals to restrict analysis to.

  vqsr_dbsnp:
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

  vqsr_outprefix:
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

  vqsr_gatk4-MakeSitesOnlyVcf_java_options:
    type: string?

  bgzip_num_threads:
    type: int
    default: 1
steps:
  joint-variant-calling:
    run: ./joint-variant-calling.cwl
    scatter: interval_bed
    in:
      sample_set: sample_set
      interval_type: interval_type
      #
      reference: reference
      dbsnp: dbsnp
      gvcfs: gvcfs
      # interval_bed: interval_bed
      genomicsDB_batch_size: genomicsDB_batch_size
      genomicsDB_interval_padding: genomicsDB_interval_padding
      # echo "outprefix: $sample_set.$interval_type.$interval_name" >> $jobfile
      # PASS.autosome_PAR_ploidy_2.
      # outprefix: outprefix
      gatk4-GenomicsDBImport_java_options: gatk4-GenomicsDBImport_java_options
      gatk4-GenomicsDBImport_num_threads: gatk4-GenomicsDBImport_num_threads
      gatk4-GenotypeGVCFs_java_options: gatk4-GenotypeGVCFs_java_options
      gatk4-VariantFiltration_java_options: gatk4-VariantFiltration_java_options
      gatk4-MakeSitesOnlyVcf_java_options: gatk4-MakeSitesOnlyVcf_java_options

      interval_bed:
        source: interval_bed_list
        valueFrom: $(self.interval_bed)
      outprefix:
        valueFrom: $(inputs.sample_set+"."+inputs.interval_type+"."+inputs.interval_bed.interval_bed.basename)
    out:
      - genomics-db
      - vcf
      - sites_only_vcf
      - genomics-db_log
      - joint-call_log
      - filter-ExcessHet_log
      - sites-only_log

  vqsr:
    run: ./vqsr.cwl
    in:
      reference_dict: reference_dict
      interval_list: interval_list
      dbsnp: vqsr_dbsnp
      mills: mills
      axiom: axiom
      hapmap: hapmap
      omni: omni
      one_thousand_genomes: one_thousand_genomes
      vcfs: joint-variant-calling/vcf
      outprefix: vqsr_outprefix
      indel_recalibration_tranche_values: indel_recalibration_tranche_values
      indel_recalibration_annotation_values: indel_recalibration_annotation_values
      indel_max_gaussians: indel_max_gaussians
      indel_truth_sensitivity_filter_level: indel_truth_sensitivity_filter_level
      snp_recalibration_tranche_values: snp_recalibration_tranche_values
      snp_recalibration_annotation_values: snp_recalibration_annotation_values
      snp_max_gaussians: snp_max_gaussians
      snp_truth_sensitivity_filter_level: snp_truth_sensitivity_filter_level
      gatk4-GatherVcfs_java_options: gatk4-GatherVcfs_java_options
      gatk4-VariantRecalibrator-INDEL_java_options: gatk4-VariantRecalibrator-INDEL_java_options
      gatk4-VariantRecalibrator-SNP_java_options: gatk4-VariantRecalibrator-SNP_java_options
      gatk4-ApplyVQSR-INDEL_java_options: gatk4-ApplyVQSR-INDEL_java_options
      gatk4-ApplyVQSR-SNP_java_options: gatk4-ApplyVQSR-SNP_java_options
      gatk4-CollectVariantCallingMetrics_java_options: gatk4-CollectVariantCallingMetrics_java_options
      gatk4-CollectVariantCallingMetrics_num_threads: gatk4-CollectVariantCallingMetrics_num_threads
      gatk4-MakeSitesOnlyVcf_java_options: vqsr_gatk4-MakeSitesOnlyVcf_java_options
      bgzip_num_threads: bgzip_num_threads

    out:
      - gather-vcfs_log
      - vqsr-INDEL_plot
      - vqsr-SNP_plot
      - vqsr-SNP_tranches
      - filnal_vcf
      - final_tbi
      - sites_only_vcf
      - sites_only_tbi
      - summary_metrics
      - detail_metrics
      - vqsr-INDEL_log
      - vqsr-SNP_log
      - apply-vqsr-INDEL_log
      - apply-vqsr-SNP_log
      - metrics_log
      - bgzip_log
      - sites-only_log
      - bgzip-sites-only_log
      

outputs:
  genomics-db:
    type: Directory[]
    outputSource: joint-variant-calling/genomics-db

  vcf:
    type: File[]
    format: edam:format_3016
    secondaryFiles:
      - .idx
    outputSource: joint-variant-calling/vcf

  sites_only_vcf:
    type: File[]
    format: edam:format_3016
    secondaryFiles:
      - .idx
    outputSource: joint-variant-calling/sites_only_vcf
    
  genomics-db_log:
    type: File[]
    outputSource: joint-variant-calling/genomics-db_log

  joint-call_log:
    type: File[]
    outputSource: joint-variant-calling/joint-call_log

  filter-ExcessHet_log:
    type: File[]
    outputSource: joint-variant-calling/filter-ExcessHet_log

  sites-only_log:
    type: File[]
    outputSource: joint-variant-calling/sites-only_log

##

  gather-vcfs_log:
    type: File
    outputSource: vqsr/gather-vcfs_log

  vqsr-INDEL_plot:
    type: File
    outputSource: vqsr/vqsr-INDEL_plot
    
  vqsr-SNP_plot:
    type: File
    outputSource: vqsr/vqsr-SNP_plot

  vqsr-SNP_tranches:
    type: File
    outputSource: vqsr/vqsr-SNP_tranches
    
  filnal_vcf:
    type: File
    format: edam:format_3016
    outputSource: vqsr/filnal_vcf

  final_tbi:
    type: File
    outputSource: vqsr/final_tbi

  vqsr_sites_only_vcf:
    type: File
    format: edam:format_3016
    outputSource: vqsr/sites_only_vcf

  sites_only_tbi:
    type: File
    outputSource: vqsr/sites_only_tbi
    
  summary_metrics:
    type: File
    outputSource: vqsr/summary_metrics
    
  detail_metrics:
    type: File
    outputSource: vqsr/detail_metrics
  
  vqsr-INDEL_log:
    type: File
    outputSource: vqsr/vqsr-INDEL_log

  vqsr-SNP_log:
    type: File
    outputSource: vqsr/vqsr-SNP_log

  apply-vqsr-INDEL_log:
    type: File
    outputSource: vqsr/apply-vqsr-INDEL_log

  apply-vqsr-SNP_log:
    type: File
    outputSource: vqsr/apply-vqsr-SNP_log

  metrics_log:
    type: File
    outputSource: vqsr/metrics_log
    
  bgzip_log:
    type: File
    outputSource: vqsr/bgzip_log
    
  vqsr_sites-only_log:
    type: File
    outputSource: vqsr/sites-only_log

  bgzip-sites-only_log:
    type: File
    outputSource: vqsr/bgzip-sites-only_log
