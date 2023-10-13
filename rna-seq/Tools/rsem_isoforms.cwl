#!/usr/bin/env cwl-runner

class: CommandLineTool
id: rsem_isoforms
label: rsem_aggregate
cwlVersion: v1.2

requirements:
  ResourceRequirement:
    ramMin: 64
    coresMin: 16
  DockerRequirement:
    dockerPull: docker://yamaken37/rsem_aggr:20231010
  InlineJavascriptRequirement: {}

baseCommand: [python, /TSCA/ccle_processing/RNA_pipeline/aggregate_rsem_results.py]

arguments:
  - valueFrom: |
      $(inputs.file_list.map(f => f.path).join('\n'))
    position: 1
    separate: false

inputs:
  file_list:
    type: File[]
    inputBinding:
      position: 2

inputs:
  sh_rsem:
    type: File
    inputBinding:
      position: 1
  rsem_isoforms:
    type: File
    inputBinding:
      position: 2
  prefix_rsem:
    type: string
    inputBinding:
      position: 3
  rsem_genes:
    type: File
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
