#!/usr/bin/env cwl-runner

class: Workflow
id: CoverageAtEveryBase
label: CoverageAtEveryBase
cwlVersion: v1.1

$namespaces:
  edam: http://edamontology.org/

requirements:
  InlineJavascriptRequirement: {}

inputs:
  input_bam_regular_ref:
    type: File
    format: edam:format_2572
    secondaryFiles:
      - ^.bai
  input_bam_shifted_ref:
    type: File
    format: edam:format_2572
    secondaryFiles:
      - ^.bai
  shift_back_chain:
    type: File
    format: edam:format_3982
  control_region_shifted_reference_interval_list:
    type: File
  non_control_region_interval_list:
    type: File
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
  mt_shifted_reference:
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
  outprefix:
    type: string

steps:
  CollectHsMetricsNonControlRegion:
    label: CollectHsMetricsNonControlRegion
    run: ../Tools/CoverageAtEveryBase/CollectHsMetrics.cwl
    in:
      reference: mt_reference
      bam: input_bam_regular_ref
      interval_list: non_control_region_interval_list
      outprefix:
        source: outprefix
        valueFrom: $(self).non_control_region
    out: [per_base_coverage, log]
  CollectHsMetricsControlRegionShifted:
    label: CollectHsMetricsControlRegion
    run: ../Tools/CoverageAtEveryBase/CollectHsMetrics.cwl
    in:
      reference: mt_shifted_reference
      bam: input_bam_shifted_ref
      interval_list: control_region_shifted_reference_interval_list
      outprefix:
        source: outprefix
        valueFrom: $(self).control_region_shifted
    out: [per_base_coverage, log]
  CombineTable:
    label: CombineTable
    run: ../Tools/CoverageAtEveryBase/CombineTable.cwl
    in:
      non_control_region: CollectHsMetricsNonControlRegion/per_base_coverage
      control_region_shifted: CollectHsMetricsControlRegionShifted/per_base_coverage
      outprefix: outprefix
    out: [per_base_coverage, log]

outputs:
  per_base_coverage:
    type: File
    outputSource: CombineTable/per_base_coverage
  #
  # The followings are not listed in the original WDL
  #
  CollectHsMetricsNonControlRegion_log:
    type: File
    outputSource: CollectHsMetricsNonControlRegion/log
  CollectHsMetricsControlRegionShifted_log:
    type: File
    outputSource: CollectHsMetricsControlRegionShifted/log
  CombineTable_log:
    type: File
    outputSource: CombineTable/log
