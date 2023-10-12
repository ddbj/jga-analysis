#!/usr/bin/env cwl-runner

class: Workflow
id: rsem_aggregate_results_wf
label: rsem_aggregate
cwlVersion: v1.2

requirements:
  StepInputExpressionRequirement: {}

inputs:
  sh_rsem:
    type: File
  rsem_isoforms:
    type: File[]
  rsem_genes:
    type: File[]
  prefix_rsem: #prefixのままだとややこしいので変更
    type: string

steps:
  rsem_isoforms_w:
    run: ../Tools/write_line.cwl
    in:
      file_list: rsem_isoforms
    out:
      - write_line_file
  rsem_genes_w:
    run: ../Tools/write_line.cwl
    in:
      file_list: rsem_genes
    out:
      - write_line_file
  rsem_aggregate_results:
    run: ../Tools/rsem_aggregate_results.cwl
    in:
      sh_rsem: sh_rsem
      rsem_isoforms: rsem_isoforms_w/write_line_file
      prefix_rsem: prefix_rsem
      rsem_genes: rsem_genes_w/write_line_file
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