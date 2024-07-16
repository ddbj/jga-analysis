#!/usr/bin/env cwl-runner

class: CommandLineTool
id: gatk4-GatherVariantCallingMetrics-biggest-practices
label: gatk4-GatherVariantCallingMetrics-biggest-practices
cwlVersion: v1.1

requirements:
  DockerRequirement:
    dockerPull: us.gcr.io/broad-gatk/gatk:4.5.0.0
  ShellCommandRequirement: {}
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - entry: $(inputs.metricsDir)

baseCommand: [gatk]

inputs:
  java_options:
    type: string?
    default: -Xms2000m -Xmx2500m
    inputBinding:
      position: 1
      prefix: --java-options
      shellQuote: true
  input_details:
    type:
      type: array
      items: string
      inputBinding:
        prefix: --INPUT
    inputBinding:
      position: 3
  metricsDir:
    type: Directory
  output_prefix:
    type: string
    doc: (ex) gnarly_callset
    inputBinding:
      prefix: --OUTPUT
      position: 4

outputs:
  detail_metrics_file:
    type: File
    outputBinding:
      glob: $(inputs.output_prefix).variant_calling_detail_metrics
  summary_metrics_file:
    type: File
    outputBinding:
      glob: $(inputs.output_prefix).variant_calling_summary_metrics

stderr: $(inputs.output_prefix).variant_calling_detail_metrics.log

arguments:
  - position: 2
    valueFrom: AccumulateVariantCallingMetrics
