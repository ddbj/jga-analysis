#!/usr/bin/env cwl-runner

class: CommandLineTool
id: gatk4-CollectMetricsSharded-biggest-practices
label: gatk4-CollectMetricsSharded-biggest-practices
cwlVersion: v1.1

requirements:
  DockerRequirement:
    dockerPull: us.gcr.io/broad-gatk/gatk:4.5.0.0
  ShellCommandRequirement: {}
  InlineJavascriptRequirement: {}

inputs:
  java_options:
    type: string?
    default: -Xms6000m -Xmx7000m
    inputBinding:
      position: 1
      prefix: --java-options
      shellQuote: true
  input_vcf:
    type: File
    inputBinding:
      position: 3
      prefix: --INPUT
    secondaryFiles:
      - .tbi
  dbsnp_vcf:
    type: File
    inputBinding:
      position: 4
      prefix: --DBSNP
    secondaryFiles:
      - .idx
  ref_dict:
    type: File
    inputBinding:
      position: 5
      prefix: --SEQUENCE_DICTIONARY
  THREAD_COUNT:
    type: int
    default: 8
    inputBinding:
      prefix: --THREAD_COUNT
      position: 7
  interval_list:
    type: File
    inputBinding:
      position: 8
      prefix: --TARGET_INTERVALS
  callset_name:
    type: string
    doc: (ex) gnarly_callset
  idx:
    type: int
    doc: unpadded_intervals, row number

outputs:
  detail_metrics_file:
    type: File
    outputBinding:
      glob: $(inputs.callset_name).$(inputs.idx).variant_calling_detail_metrics
  summary_metrics_file:
    type: File
    outputBinding:
      glob: $(inputs.callset_name).$(inputs.idx).variant_calling_summary_metrics

stderr: $(inputs.callset_name).$(inputs.idx).variant_calling_detail_metrics.log

arguments:
  - position: 2
    valueFrom: CollectVariantCallingMetrics
  - position: 6
    prefix: --OUTPUT
    valueFrom: $(inputs.callset_name).$(inputs.idx)