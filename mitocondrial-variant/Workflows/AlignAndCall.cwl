#!/usr/bin/env cwl-runner

class: Workflow
id: AlignAndCall
label: AlignAndCall
doc: Takes in unmapped bam and outputs VCF of SNP/Indel calls on the mitochondria
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

requirements:
  SubworkflowFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}

inputs:
  unmapped_bam:
    doc: Unmapped and subset bam, optionally with original alignment (OA) tag
    type: File
    format: edam:format_2572
  autosomal_coverage:
    # In the original WDL implementation, input parameter `autosomal_coverage` is optional.
    # If it is defined, task `FilterNuMTs` is run (otherwise not run).
    # In this CWL implementation, the parameter is mandatory and step `FilterNuMTs` is always executed.
    type: float
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
  m2_extra_args:
    type: string?
  m2_filter_extra_args:
    type: string?
  vaf_filter_threshold:
    type: float?
  f_score_beta:
    type: float?
  verifyBamID:
    type: float?
  max_low_het_sites:
    type: int?
  max_read_length:
    doc: >-
      Read length used for optimization only. If this is too small
      CollectWgsMetrics might fail, but the results are not affected by
      this number. Default is 151.
    type: int?
  outprefix:
    type: string

steps:
  AlignToMt:
    label: AlignToMt
    run: AlignAndMarkDuplicates.cwl
    in:
      reference: mt_reference
      unmapped_bam: unmapped_bam
      outprefix:
        source: outprefix
        valueFrom: $(self).alignedToMt
    out: [bam, duplicate_metrics, BWA_log, Align_log, MarkDuplicates_log, SortSam_log]
  AlignToShiftedMt:
    label: AlignToShiftedMt
    run: AlignAndMarkDuplicates.cwl
    in:
      reference: mt_shifted_reference
      unmapped_bam: unmapped_bam
      outprefix:
        source: outprefix
        valueFrom: $(self).alignedToShiftedMt
    out: [bam, duplicate_metrics, BWA_log, Align_log, MarkDuplicates_log, SortSam_log]
  CollectWgsMetrics:
    label: CollectWgsMetrics
    run: ../Tools/AlignAndCall/CollectWgsMetrics.cwl
    in:
      bam: AlignToMt/bam
      reference: mt_reference
      read_length: max_read_length
      coverage_cap:
        default: 100000
    out: [coverage_metrics, theoretical_sensitivity, log]
  MeanCoverage:
    label: MeanCoverage
    run: ../Tools/AlignAndCall/MeanCoverage.cwl
    in:
      coverage_metrics: CollectWgsMetrics/coverage_metrics
    out: [mean_coverage, log]
  CallMt:
    label: CallMt
    run: ../Tools/AlignAndCall/M2.cwl
    in:
      # NOTE: may need to set `java_options`
      reference: mt_reference
      bam: AlignToMt/bam
      m2_extra_args:
        source: m2_extra_args
        valueFrom: $([self, "-L chrM:576-16024"].filter(Boolean).join(" "))
    out: [raw_vcf, stats, log]
  CallShiftedMt:
    label: CallShiftedMt
    run: ../Tools/AlignAndCall/M2.cwl
    in:
      # NOTE: may need to set `java_options`
      reference: mt_shifted_reference
      bam: AlignToShiftedMt/bam
      m2_extra_args:
        source: m2_extra_args
        valueFrom: $([self, "-L chrM:8025-9144"].filter(Boolean).join(" "))
    out: [raw_vcf, stats, log]
  LiftoverVcf:
    label: LiftoverVcf
    run: ../Tools/AlignAndCall/LiftoverVcf.cwl
    in:
      shifted_vcf: CallShiftedMt/raw_vcf
      reference: mt_reference
      shift_back_chain: shift_back_chain
    out: [shifted_back_vcf, log]
  MergeVcfs:
    label: MergeVcfs
    run: ../Tools/AlignAndCall/MergeVcfs.cwl
    in:
      shifted_back_vcf: LiftoverVcf/shifted_back_vcf
      vcf: CallMt/raw_vcf
      outprefix: outprefix
    out: [merged_vcf, log]
  MergeStats:
    label: MergeStats
    run: ../Tools/AlignAndCall/MergeStats.cwl
    in:
      shifted_stats: CallShiftedMt/stats
      non_shifted_stats: CallMt/stats
      outprefix: outprefix
    out:
      [stats, log]
  InitialFilter:
    label: InitialFilter
    run: ../Workflows/Filter.cwl
    in:
      reference: mt_reference
      raw_vcf: MergeVcfs/merged_vcf
      raw_vcf_stats: MergeStats/stats
      m2_extra_filtering_args: m2_filter_extra_args
      max_alt_allele_count:
        default: 4
      vaf_filter_threshold:
        default: 0
      f_score_beta: f_score_beta
      run_contamination:
        default: false
      blacklisted_sites: blacklisted_sites
      outprefix:
        source: outprefix
        valueFrom: $(self).initialFilter
    out: [filtered_vcf, FilterMutectCalls_log, VariantFiltration_log]
  SplitMultiAllelicSites:
    label: SplitMultiAllelicSites
    run: ../Tools/SplitMultiAllelicSites.cwl
    in:
      reference: mt_reference
      in_vcf: InitialFilter/filtered_vcf
    out: [split_vcf, log]
  RemoveNonPassSites:
    label: RemoveNonPassSites
    run: ../Tools/AlignAndCall/RemoveNonPassSites.cwl
    in:
      in_vcf: SplitMultiAllelicSites/split_vcf
    out: [out_vcf, log]
  GetContamination:
    label: GetContamination
    run: ../Tools/AlignAndCall/GetContamination.cwl
    in:
      vcf: RemoveNonPassSites/out_vcf
    out:
      - contamination
      - hasContamination
      - minor_hg
      - major_hg
      - minor_level
      - major_level
      - log
  FilterContamination:
    label: InitialFilter
    run: ../Workflows/Filter.cwl
    in:
      reference: mt_reference
      raw_vcf: InitialFilter/filtered_vcf
      raw_vcf_stats: MergeStats/stats
      m2_extra_filtering_args: m2_filter_extra_args
      max_alt_allele_count:
        default: 4
      vaf_filter_threshold: vaf_filter_threshold
      f_score_beta: f_score_beta
      run_contamination:
        default: true
      hasContamination: GetContamination/hasContamination
      contamination_major: GetContamination/major_level
      contamination_minor: GetContamination/minor_level
      verifyBamID: verifyBamID
      blacklisted_sites: blacklisted_sites
      outprefix:
        source: outprefix
        valueFrom: $(self).filterContamination
    out: [filtered_vcf, contamination, FilterMutectCalls_log, VariantFiltration_log]
  FilterNuMTs:
    label: FilterNuMTs
    run: ../Tools/AlignAndCall/FilterNuMTs.cwl
    in:
      reference: mt_reference
      in_vcf: FilterContamination/filtered_vcf
      autosomal_coverage: autosomal_coverage
      outprefix:
        source: outprefix
        valueFrom: $(self).filterNuMTs
    out: [out_vcf, log]
  FilterLowHetSites:
    label: FilterLowHetSites
    run: ../Tools/AlignAndCall/FilterLowHetSites.cwl
    in:
      reference: mt_reference
      in_vcf: FilterNuMTs/out_vcf
      max_low_het_sites: max_low_het_sites
      outprefix:
        source: outprefix
        valueFrom: $(self).final
    out: [out_vcf, log]

outputs:
  mt_aligned_bam:
    type: File
    outputSource: AlignToMt/bam
    secondaryFiles:
      - ^.bai
  mt_aligned_shifted_bam:
    type: File
    outputSource: AlignToShiftedMt/bam
    secondaryFiles:
      - ^.bai
  out_vcf:
    type: File
    outputSource: FilterLowHetSites/out_vcf
  input_vcf_for_haplochecker:
    type: File
    outputSource: RemoveNonPassSites/out_vcf
  duplicate_metrics:
    type: File
    outputSource: AlignToMt/duplicate_metrics
  coverage_metrics:
    type: File
    outputSource: CollectWgsMetrics/coverage_metrics
  theoretical_sensitivity_metrics:
    type: File
    outputSource: CollectWgsMetrics/theoretical_sensitivity
  contamination_metrics:
    type: File
    outputSource: GetContamination/contamination
  mean_coverage:
    type: int
    outputSource: MeanCoverage/mean_coverage
  major_haplogroup:
    type: string
    outputSource: GetContamination/major_hg
  contamination:
    type: float
    outputSource: FilterContamination/contamination
  #
  # The followings are not listed in the original WDL
  #
  AlignToMt_BWA_log:
    type: File
    outputSource: AlignToMt/BWA_log
  AlignToMt_Align_log:
    type: File
    outputSource: AlignToMt/Align_log
  AlignToMt_MarkDuplicates_log:
    type: File
    outputSource: AlignToMt/MarkDuplicates_log
  AlignToMt_SortSam_log:
    type: File
    outputSource: AlignToMt/SortSam_log
  AlignToShiftedMt_BWA_log:
    type: File
    outputSource: AlignToShiftedMt/BWA_log
  AlignToShiftedMt_Align_log:
    type: File
    outputSource: AlignToShiftedMt/Align_log
  AlignToShiftedMt_MarkDuplicates_log:
    type: File
    outputSource: AlignToShiftedMt/MarkDuplicates_log
  AlignToShiftedMt_SortSam_log:
    type: File
    outputSource: AlignToShiftedMt/SortSam_log
  CollectWgsMetrics_log:
    type: File
    outputSource: CollectWgsMetrics/log
  MeanCoverage_log:
    type: File
    outputSource: MeanCoverage/log
  CallMt_log:
    type: File
    outputSource: CallMt/log
  CallShiftedMt_log:
    type: File
    outputSource: CallShiftedMt/log
  LiftoverVcf_log:
    type: File
    outputSource: LiftoverVcf/log
  MergeVcfs_log:
    type: File
    outputSource: MergeVcfs/log
  MergeStats_log:
    type: File
    outputSource: MergeStats/log
  InitialFilter_FilterMutectCalls_log:
    type: File
    outputSource: InitialFilter/FilterMutectCalls_log
  InitialFilter_VariantFiltration_log:
    type: File
    outputSource: InitialFilter/VariantFiltration_log
  SplitMultiAllelicSites_log:
    type: File
    outputSource: SplitMultiAllelicSites/log
  RemoveNonPassSites_log:
    type: File
    outputSource: RemoveNonPassSites/log
  GetContamination_log:
    type: File
    outputSource: GetContamination/log
  FilterContamination_FilterMutectCalls_log:
    type: File
    outputSource: FilterContamination/FilterMutectCalls_log
  FilterContamination_VariantFiltration_log:
    type: File
    outputSource: FilterContamination/VariantFiltration_log
  FilterNuMTs_log:
    type: File
    outputSource: FilterNuMTs/log
  FilterLowHetSites_log:
    type: File
    outputSource: FilterLowHetSites/log
