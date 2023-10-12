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
    # dockerPull: us-docker.pkg.dev/depmap-omics/public/ccle-rnaseq:latest
    dockerPull: docker://yamaken37/rsem_aggr:20231010

# baseCommand: [bash, ../Tools/rsem_aggregate_results.sh]
# baseCommand: [bash, /lustre8/home/yamaken-gaj-pg/Projects/RSEM-AGGR/jga-analysis/rna-seq/Tools/rsem_aggregate_results.sh]
# baseCommand: [bash, rsem_aggregate_results.sh]
baseCommand: [bash]

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
