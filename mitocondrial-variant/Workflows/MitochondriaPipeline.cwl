#!/usr/bin/env cwl-runner

class: Workflow
id: MitochondriaPipeline
label: MitochondriaPipeline
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

requirements:
  SubworkflowFeatureRequirement: {}
  StepInputExpressionRequirement: {}

inputs:
  wgs_aligned_cram:
    doc: Full WGS hg38 CRAM
    type: File
    format: edam:format_3462
    secondaryFiles:
      - .crai
  contig_name:
    doc: >-
      Name of mitochondria contig in reference that `wgs_aligned_input_bam_or_cram`
      is aligned to
    type: string
    default: chrM
  autosomal_coverage:
    doc: Median coverage of full input CRAM
    type: float
    default: 30
  max_read_length:
    doc: >-
      Read length used for optimization only. If this is too small
      CollectWgsMetrics might fail, but the results are not affected by
      this number. Default is 151.
    type: int?
  full_reference:
    type: File
    format: edam:format_1929
    secondaryFiles:
      - .fai
      - ^.dict
  mt_reference:
    type: File
    format: edam:format_1929
    secondaryFiles:
      - .fai
      - .amb
      - .ann
      - .bwt
      - .pac
      - .sa
      - ^.dict
  blacklisted_sites:
    doc: blacklist sites in BED format
    type: File
    format: edam:format_3003
    secondaryFiles:
      - .idx
  mt_shifted_reference:
    doc: >-
      Shifted reference is used for calling the control region (edge of mitochondria
      reference). This solves the problem that BWA doesn't support alignment to
      circular contigs.
    type: File
    format: edam:format_1929
    secondaryFiles:
      - .fai
      - .amb
      - .ann
      - .bwt
      - .pac
      - .sa
      - ^.dict
  shift_back_chain:
    type: File
    format: edam:format_3982
  control_region_shifted_reference_interval_list:
    type: File
  non_control_region_interval_list:
    type: File
  m2_extra_args:
    type: string?
  m2_filter_extra_args:
    type: string?
  vaf_filter_threshold:
    doc: Hard threshold for filtering low VAF sites
    type: float?
  f_score_beta:
    doc: >-
      F-Score beta balances the filtering strategy between recall and precision.
      The relative weight of recall to precision.
    type: float?
  verifyBamID:
    type: float?
  max_low_het_sites:
    type: int?
  outprefix:
    type: string

steps:
  SubsetCramToChrM:
    label: SubsetCramToChrM
    run: ../Tools/SubsetCramToChrM.cwl
    in:
      contig_name: contig_name
      full_reference: full_reference
      cram: wgs_aligned_cram
      outprefix:
        source: outprefix
        valueFrom: $(self).chrM
    out: [subset_bam, log]
  RevertSam:
    label: RevertSam
    run: ../Tools/RevertSam.cwl
    in:
      bam: SubsetCramToChrM/subset_bam
      outprefix:
        source: outprefix
        valueFrom: $(self).chrM.unmapped
    out: [unmapped_bam, log]
  AlignAndCall:
    label: AlignAndCall
    run: AlignAndCall.cwl
    in:
      unmapped_bam: RevertSam/unmapped_bam
      autosomal_coverage: autosomal_coverage
      mt_reference: mt_reference
      blacklisted_sites: blacklisted_sites
      mt_shifted_reference: mt_shifted_reference
      shift_back_chain: shift_back_chain
      m2_extra_args: m2_extra_args
      m2_filter_extra_args: m2_filter_extra_args
      vaf_filter_threshold: vaf_filter_threshold
      f_score_beta: f_score_beta
      verifyBamID: verifyBamID
      max_low_het_sites: max_low_het_sites
      max_read_length: max_read_length
      outprefix:
        source: outprefix
        valueFrom: $(self).chrM
    out:
      - mt_aligned_bam
      - mt_aligned_shifted_bam
      - out_vcf
      - input_vcf_for_haplochecker
      - duplicate_metrics
      - coverage_metrics
      - theoretical_sensitivity_metrics
      - contamination_metrics
      - mean_coverage
      - major_haplogroup
      - contamination
      - AlignToMt_BWA_log
      - AlignToMt_Align_log
      - AlignToMt_MarkDuplicates_log
      - AlignToMt_SortSam_log
      - AlignToShiftedMt_BWA_log
      - AlignToShiftedMt_Align_log
      - AlignToShiftedMt_MarkDuplicates_log
      - AlignToShiftedMt_SortSam_log
      - CollectWgsMetrics_log
      - MeanCoverage_log
      - CallMt_log
      - CallShiftedMt_log
      - LiftoverVcf_log
      - MergeVcfs_log
      - MergeStats_log
      - InitialFilter_FilterMutectCalls_log
      - InitialFilter_VariantFiltration_log
      - SplitMultiAllelicSites_log
      - RemoveNonPassSites_log
      - GetContamination_log
      - FilterContamination_FilterMutectCalls_log
      - FilterContamination_VariantFiltration_log
      - FilterNuMTs_log
      - FilterLowHetSites_log
  CoverageAtEveryBase:
    label: CoverageAtEveryBase
    run: CoverageAtEveryBase.cwl
    in:
      input_bam_regular_ref: AlignAndCall/mt_aligned_bam
      input_bam_shifted_ref: AlignAndCall/mt_aligned_shifted_bam
      shift_back_chain: shift_back_chain
      control_region_shifted_reference_interval_list: control_region_shifted_reference_interval_list
      non_control_region_interval_list: non_control_region_interval_list
      mt_reference: mt_reference
      mt_shifted_reference: mt_shifted_reference
      outprefix: outprefix
    out:
      - per_base_coverage
      - CollectHsMetricsNonControlRegion_log
      - CollectHsMetricsControlRegionShifted_log
      - CombineTable_log
  SplitMultiAllelicSites:
    label: SplitMultiAllelicSites
    run: ../Tools/SplitMultiAllelicSites.cwl
    in:
      reference: mt_reference
      in_vcf: AlignAndCall/out_vcf
    out: [split_vcf, log]

outputs:
  # In the original WDL implementation, a user can choose uncompressed or compressed VCFs as output format.
  # In out CWL implementation, output VCFs are always uncompressed.
  subset_bam:
    type: File
    outputSource: SubsetCramToChrM/subset_bam
  mt_aligned_bam:
    type: File
    outputSource: AlignAndCall/mt_aligned_bam
  out_vcf:
    type: File
    outputSource: AlignAndCall/out_vcf
  split_vcf:
    type: File
    outputSource: SplitMultiAllelicSites/split_vcf
  input_vcf_for_haplochecker:
    type: File
    outputSource: AlignAndCall/input_vcf_for_haplochecker
  duplicate_metrics:
    type: File
    outputSource: AlignAndCall/duplicate_metrics
  coverage_metrics:
    type: File
    outputSource: AlignAndCall/coverage_metrics
  theoretical_sensitivity_metrics:
    type: File
    outputSource: AlignAndCall/theoretical_sensitivity_metrics
  contamination_metrics:
    type: File
    outputSource: AlignAndCall/contamination_metrics
  base_level_coverage_metrics:
    type: File
    outputSource: CoverageAtEveryBase/per_base_coverage
  mean_coverage:
    type: int
    outputSource: AlignAndCall/mean_coverage
  major_haplogroup:
    type: string
    outputSource: AlignAndCall/major_haplogroup
  contamination:
    type: float
    outputSource: AlignAndCall/contamination
  #
  # The followings are not listed in the original WDL
  #
  SubsetCramToChrM_log:
    type: File
    outputSource: SubsetCramToChrM/log
  RevertSam_log:
    type: File
    outputSource: RevertSam/log
  AlignToMt_BWA_log:
    type: File
    outputSource: AlignAndCall/AlignToMt_BWA_log
  AlignToMt_Align_log:
    type: File
    outputSource: AlignAndCall/AlignToMt_Align_log
  AlignToMt_MarkDuplicates_log:
    type: File
    outputSource: AlignAndCall/AlignToMt_MarkDuplicates_log
  AlignToMt_SortSam_log:
    type: File
    outputSource: AlignAndCall/AlignToMt_SortSam_log
  AlignToShiftedMt_BWA_log:
    type: File
    outputSource: AlignAndCall/AlignToShiftedMt_BWA_log
  AlignToShiftedMt_Align_log:
    type: File
    outputSource: AlignAndCall/AlignToShiftedMt_Align_log
  AlignToShiftedMt_MarkDuplicates_log:
    type: File
    outputSource: AlignAndCall/AlignToShiftedMt_MarkDuplicates_log
  AlignToShiftedMt_SortSam_log:
    type: File
    outputSource: AlignAndCall/AlignToShiftedMt_SortSam_log
  CollectWgsMetrics_log:
    type: File
    outputSource: AlignAndCall/CollectWgsMetrics_log
  MeanCoverage_log:
    type: File
    outputSource: AlignAndCall/MeanCoverage_log
  CallMt_log:
    type: File
    outputSource: AlignAndCall/CallMt_log
  CallShiftedMt_log:
    type: File
    outputSource: AlignAndCall/CallShiftedMt_log
  LiftoverVcf_log:
    type: File
    outputSource: AlignAndCall/LiftoverVcf_log
  MergeVcfs_log:
    type: File
    outputSource: AlignAndCall/MergeVcfs_log
  MergeStats_log:
    type: File
    outputSource: AlignAndCall/MergeStats_log
  InitialFilter_FilterMutectCalls_log:
    type: File
    outputSource: AlignAndCall/InitialFilter_FilterMutectCalls_log
  InitialFilter_VariantFiltration_log:
    type: File
    outputSource: AlignAndCall/InitialFilter_VariantFiltration_log
  AlignAndCall_SplitMultiAllelicSites_log:
    type: File
    outputSource: AlignAndCall/SplitMultiAllelicSites_log
  RemoveNonPassSites_log:
    type: File
    outputSource: AlignAndCall/RemoveNonPassSites_log
  GetContamination_log:
    type: File
    outputSource: AlignAndCall/GetContamination_log
  FilterContamination_FilterMutectCalls_log:
    type: File
    outputSource: AlignAndCall/FilterContamination_FilterMutectCalls_log
  FilterContamination_VariantFiltration_log:
    type: File
    outputSource: AlignAndCall/FilterContamination_VariantFiltration_log
  FilterNuMTs_log:
    type: File
    outputSource: AlignAndCall/FilterNuMTs_log
  FilterLowHetSites_log:
    type: File
    outputSource: AlignAndCall/FilterLowHetSites_log
  CollectHsMetricsNonControlRegion_log:
    type: File
    outputSource: CoverageAtEveryBase/CollectHsMetricsNonControlRegion_log
  CollectHsMetricsControlRegionShifted_log:
    type: File
    outputSource: CoverageAtEveryBase/CollectHsMetricsControlRegionShifted_log
  CoverageAtEveryBase_CombineTable_log:
    type: File
    outputSource: CoverageAtEveryBase/CombineTable_log
  SplitMultiAllelicSites_log:
    type: File
    outputSource: SplitMultiAllelicSites/log
