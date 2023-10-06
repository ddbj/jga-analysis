#!/usr/bin/env cwl-runner

class: Workflow
id: rsem_aggregate_results_wf
label: rsem_aggregate
cwlVersion: v1.2

requirements:
  StepInputExpressionRequirement: {}

inputs:
  rsem_isoforms:
    type: File[]
  rsem_genes:
    type: File[]
  prefix_rsem: #prefixのままだとややこしいので変更
    type: string
steps:
  rsem_aggregate_results:
    run: ../Tools/rsem_aggregate_results.cwl
    in:
      rsem_isoforms: rsem_isoforms
      rsem_genes: rsem_genes
      prefix_rsem: prefix_rsem
    out:
      - transcripts_tpm
      - transcripts_isopct
      - transcripts_expected_count
      - genes_tpm
      - genes_expected_count
outputs:
  transcripts_tpm:
    type: File
    outputSource: rsem_aggregate_results/transcripts_tpm
  transcripts_isopct:
    type: File
    outputSource: rsem_aggregate_results/transcripts_isopct
  transcripts_expected_count:
    type: File
    outputSource: rsem_aggregate_results/transcripts_expected_count
  genes_tpm:
    type: File
    outputSource: rsem_aggregate_results/genes_tpm
  genes_expected_count:
    type: File
    outputSource: rsem_aggregate_results/genes_expected_count