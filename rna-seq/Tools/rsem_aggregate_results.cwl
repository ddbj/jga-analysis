#!/usr/bin/env cwl-runner

class: CommandLineTool
id: rsem_aggregate_results
label: rsem_aggregate
cwlVersion: v1.2

requirements:
  ResourceRequirement:
    ramMin: 64
    coresMin: 16
  DockerRequirement:
    dockerPull: us-docker.pkg.dev/depmap-omics/public/ccle-rnaseq:latest

baseCommand: [bash, rsem_aggregate_results.sh]

inputs:
  rsem_isoforms:
    type: File[]
    inputBinding:
      position: 1
  prefix_rsem:
    type: string
    inputBinding:
      position: 2
  rsem_genes:
    type: File[]
    inputBinding:
      position: 3

outputs:
    transcripts_tpm:
      type: File
      outputBinding:
        glob: "$(inputs.prefix_rsem).rsem_transcripts_tpm.txt.gz"
    transcripts_isopct:
      type: File
      outputBinding:
        glob: "$(inputs.prefix_rsem).rsem_transcripts_isopct.txt.gz"
    transcripts_expected_count:
      type: File
      outputBinding:
        glob: "$(inputs.prefix_rsem).rsem_transcripts_expected_count.txt.gz"
    genes_tpm:
      type: File
      outputBinding:
        glob: "$(inputs.prefix_rsem).rsem_genes_tpm.txt.gz"
    genes_expected_count:
      type: File
      outputBinding:
        glob: "$(inputs.prefix_rsem).rsem_genes_expected_count.txt.gz"
