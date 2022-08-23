#!/usr/bin/env cwl-runner

class: Workflow
id: somatic-variant-call-TN
label: somatic-variant-call-TN
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

requirements:
  MultipleInputFeatureRequirement: {}
  # The above is required to pass Mutect2/f1r2_tar_gz (a single file) to LearnReadOrientationModel,
  # which should take an array of files as an input
  StepInputExpressionRequirement: {}
  # The above is required to use "valueFrom" in a workflow step
  InlineJavascriptRequirement: {}
  # The above is required to evaluate $(true) and $(false) expression

inputs:
  reference:
    type: File
    format: edam:format_1929
    secondaryFiles:
      - .fai
      - ^.dict
  reference_version:
    type: string
    default: hg38
  tumor_cram:
    type: File
    format: edam:format_3462
    secondaryFiles:
      - .crai
  normal_cram:
    type: File
    format: edam:format_3462
    secondaryFiles:
      - .crai
  tumor_name:
    doc: tumor sample name
    type: string
  normal_name:
    doc: normal sample name
    type: string
  germline_resource:
    doc: e.g. af-only-gnomad.hg38.vcf.gz
    type: File
    format: edam:format_3016
    secondaryFiles:
      - .tbi
  panel_of_normals:
    type: File
    format: edam:format_3016
    secondaryFiles:
      - .tbi
  interval_list:
    type: File?
  variants_for_contamination:
    doc: e.g. small_exac_common_3.hg38.vcf.gz
    type: File
    format: edam:format_3016
    secondaryFiles:
      - .tbi
  sequencing_center:
    type: string
    default: Unknown
  sequence_source:
    doc: WGS or WXS for whole genome or whole exome sequencing, respectively
    type: string
    default: Unknown
  Mutect2_java_options:
    type: string?
  Mutect2_native_pair_hmm_threads:
    type: int?
  Mutect2_extra_args:
    type: string?
  GetPileupSummaries_java_options:
    type: string?
  GetPileupSummaries_extra_args:
    type: string?
  CalculateContamination_java_options:
    type: string?
  LearnReadOrientationModel_java_options:
    type: string?
  FilterMutectCalls_java_options:
    type: string?
  FilterMutectCalls_extra_args:
    type: string?
  Funcotator_java_options:
    type: string?
  Funcotator_data_sources:
    type: Directory
  Funcotator_transcript_selection_mode:
    type: string?
  Funcotator_transcript_selection_list:
    type: File?
  Funcotator_annotation_defaults:
    type:
      type: array
      items: string
    default: []
  Funcotator_annotation_overrides:
    type:
      type: array
      items: string
    default: []
  Funcotator_excluded_fields:
    type:
      type: array
      items: string
    default: []
  Funcotator_filter_funcotations:
    doc: ignore/drop variants that have been filtered in the input
    type: boolean
    default: false
  Funcotator_extra_args:
    type: string?
  outprefix:
    type: string

steps:
  Mutect2:
    label: Mutect2
    run: ../Tools/Mutect2.cwl
    in:
      java_options: Mutect2_java_options
      reference: reference
      tumor_cram: tumor_cram
      normal_cram: normal_cram
      normal_name: normal_name
      germline_resource: germline_resource
      interval_list: interval_list
      panel_of_normals: panel_of_normals
      native_pair_hmm_threads: Mutect2_native_pair_hmm_threads
      extra_args: Mutect2_extra_args
      outprefix: outprefix
    out: [vcf_gz, stats, f1r2_tar_gz, log]
  GetPileupSummaries_tumor:
    label: GetPileupSummaries
    run: ../Tools/GetPileupSummaries.cwl
    in:
      java_options: GetPileupSummaries_java_options
      reference: reference
      cram: tumor_cram
      is_tumor:
        valueFrom: $(true)
      interval_list: interval_list
      variants_for_contamination: variants_for_contamination
      extra_args: GetPileupSummaries_extra_args
      outprefix: outprefix
    out: [pileups, log]
  GetPileupSummaries_normal:
    label: GetPileupSummaries
    run: ../Tools/GetPileupSummaries.cwl
    in:
      java_options: GetPileupSummaries_java_options
      reference: reference
      cram: normal_cram
      is_tumor:
        valueFrom: $(false)
      interval_list: interval_list
      variants_for_contamination: variants_for_contamination
      extra_args: GetPileupSummaries_extra_args
      outprefix: outprefix
    out: [pileups, log]
  CalculateContamination:
    label: CalculateContamination
    run: ../Tools/CalculateContamination.cwl
    in:
      java_options: CalculateContamination_java_options
      tumor_pileups: GetPileupSummaries_tumor/pileups
      normal_pileups: GetPileupSummaries_normal/pileups
      outprefix: outprefix
    out: [contamination_table, tumor_segmentation, log]
  LearnReadOrientationModel:
    label: LearnReadOrientationModel
    run: ../Tools/LearnReadOrientationModel.cwl
    in:
      java_options: LearnReadOrientationModel_java_options
      f1r2_tar_gz:
        source: [Mutect2/f1r2_tar_gz]
        linkMerge: merge_flattened
      outprefix: outprefix
    out: [artifact_priors, log]
  FilterMutectCalls:
    label: FilterMutectCalls
    run: ../Tools/FilterMutectCalls.cwl
    in:
      java_options: FilterMutectCalls_java_options
      reference: reference
      in_vcf_gz: Mutect2/vcf_gz
      contamination_table: CalculateContamination/contamination_table
      tumor_segmentation: CalculateContamination/tumor_segmentation
      orientation_bias_artifact_priors: LearnReadOrientationModel/artifact_priors
      stats: Mutect2/stats
      extra_args: FilterMutectCalls_extra_args
      outprefix: outprefix
    out: [out_vcf_gz, filtering_stats, log]
  Funcotator:
    label: Funcotator
    run: ../Tools/Funcotator.cwl
    in:
      java_options: Funcotator_java_options
      reference: reference
      reference_version: reference_version
      in_vcf_gz: FilterMutectCalls/out_vcf_gz
      data_sources: Funcotator_data_sources
      interval_list: interval_list
      tumor_name: tumor_name
      normal_name: normal_name
      sequencing_center: sequencing_center
      sequence_source: sequence_source
      transcript_selection_mode: Funcotator_transcript_selection_mode
      transcript_selection_list: Funcotator_transcript_selection_list
      annotation_defaults: Funcotator_annotation_defaults
      annotation_overrides: Funcotator_annotation_overrides
      excluded_fields: Funcotator_excluded_fields
      filter_funcotations: Funcotator_filter_funcotations
      extra_args: Funcotator_extra_args
      outprefix: outprefix
    out: [maf, log]

outputs:
  filtered_vcf:
    type: File
    outputSource: FilterMutectCalls/out_vcf_gz
  filtering_stats:
    type: File
    outputSource: FilterMutectCalls/filtering_stats
  mutect_stats:
    type: File
    outputSource: Mutect2/stats
  contamination_table:
    type: File
    outputSource: CalculateContamination/contamination_table
  tumor_segmentation:
    type: File
    outputSource: CalculateContamination/tumor_segmentation
  read_orientation_model_params:
    type: File
    outputSource: LearnReadOrientationModel/artifact_priors
  funcotated_maf:
    type: File
    outputSource: Funcotator/maf
  Mutect2_log:
    type: File
    outputSource: Mutect2/log
  GetPileupSummaries_tumor_log:
    type: File
    outputSource: GetPileupSummaries_tumor/log
  GetPileupSummaries_normal_log:
    type: File
    outputSource: GetPileupSummaries_normal/log
  CalculateContamination_log:
    type: File
    outputSource: CalculateContamination/log
  LearnReadOrientationModel_log:
    type: File
    outputSource: LearnReadOrientationModel/log
  FilterMutectCalls_log:
    type: File
    outputSource: FilterMutectCalls/log
  Funcotator_log:
    type: File
    outputSource: Funcotator/log
