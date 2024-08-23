#!/usr/bin/env cwl-runner

class: CommandLineTool
id: rsem_aggr
label: rsem_aggregate
cwlVersion: v1.2

requirements:
  ResourceRequirement:
    ramMin: 4096
    coresMin: 8
  DockerRequirement:
    dockerPull: yamaken37/rsem_aggr:20231213

baseCommand: [bash, /TSCA/rsem_aggr.sh]

inputs:
  rsem_isoforms:
    type: File[]
    inputBinding:
      position: 1
      prefix: "-i"
  rsem_genes:
    type: File[]
    inputBinding:
      position: 2
      prefix: "-g"
  prefix_rsem:
    type: string
    inputBinding:
      position: 3
      prefix: "-p"

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