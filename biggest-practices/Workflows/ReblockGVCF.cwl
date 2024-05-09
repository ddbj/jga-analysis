#!/usr/bin/env cwl-runner

class: Workflow
id: ReblockGVCF
label: ReblockGVCF
cwlVersion: v1.2

requirements:
  ScatterFeatureRequirement: {}

inputs:
  ref_fasta: 
    type: File
    secondaryFiles:
      - .fai
      - ^.dict
  sample_list:
    type: File[]
    secondaryFiles:
      - .tbi

outputs:
  output_vcfs:
    type: File[]
    outputSource: reblock/output_vcf

steps:
  reblock:
    run: ../Tools/Reblock.cwl
    scatter: gvcf
    in:
      ref_fasta: ref_fasta
      gvcf: sample_list
    out: [output_vcf, output_vcf_index]