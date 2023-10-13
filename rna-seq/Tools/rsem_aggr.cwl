#!/usr/bin/env cwl-runner

class: CommandLineTool
id: rsem_aggr
label: rsem_aggregate
cwlVersion: v1.2

requirements:
  ResourceRequirement:
    ramMin: 64
    coresMin: 16
  DockerRequirement:
    dockerPull: docker://yamaken37/rsem_aggr:20231010

baseCommand: [bash]

inputs:
  sh_rsem: #rsem_aggr.sh
    type: File
    inputBinding:
      position: 1
  rsem_isoforms:
    type: File[]
    inputBinding:
      position: 2
      prefix: "-rsem_isoforms"
  rsem_genes:
    type: File[]
    inputBinding:
      position: 3
      prefix: "-rsem_genes"
  prefix_rsem:
    type: string
    inputBinding:
      position: 4

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