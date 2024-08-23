#!/usr/bin/env cwl-runner

class: CommandLineTool
id: rnaseq_rsem_quant
label: rsem_quant
cwlVersion: v1.2

requirements:
  ResourceRequirement:
    ramMin: 4096
    coresMin: 8
  DockerRequirement:
    dockerPull: encodedcc/rna-seq-pipeline:1.2.4
baseCommand: [python3, /software/rna-seq-pipeline/src/rsem_quant.py]

inputs:
  rsem_index:
    type: File
    inputBinding:
      position: 1
      prefix: "--rsem_index"
  anno_bam:
    type: File
    inputBinding:
      position: 2
      prefix: "--anno_bam"
  endedness:
    type: string
    inputBinding:
      position: 3
      prefix: "--endedness"
  read_strand:
    type: string
    inputBinding:
      position: 4
      prefix: "--read_strand"
  rnd_seed:
    type: int
    inputBinding:
      position: 5
      prefix: "--rnd_seed"
  ncpus:
    type: int
    inputBinding:
      position: 6
      prefix: "--ncpus"
  ramGB:
    type: int
    inputBinding:
      position: 7
      prefix: "--ramGB"
  disks:  
    type: string?

outputs:
    genes_results:
      type: File
      outputBinding:
        glob: '*.genes.results'
    isoforms_results:
      type: File
      outputBinding:
        glob: "*.isoforms.results"
    number_of_genes:
      type: File
      outputBinding:
        glob: "*_number_of_genes_detected.json"
    python_log:
      type: File
      outputBinding:
        glob: "rsem_quant.log"