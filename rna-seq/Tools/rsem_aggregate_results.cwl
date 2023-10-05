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
  fastqs_R1:
    type: File[]
    inputBinding:
      position: 1
      prefix: "--fastqs_R1"
  fastqs_R2:
    type: File[]
    inputBinding:
      position: 2
      prefix: "--fastqs_R2"
  endedness:
    type: string
    inputBinding:
      position: 3
      prefix: "--endedness"
  index:
    type: File
    inputBinding:
      position: 4
      prefix: "--index"
  bamroot:
    type: string
    inputBinding:
      position: 5
      prefix: "--bamroot"
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

outputs:
    genomebam:
      type: File
      outputBinding:
        glob: "$(inputs.bamroot)_genome.bam"
    annobam:
      type: File
      outputBinding:
        glob: "$(inputs.bamroot)_anno.bam"
    genome_flagstat:
      type: File
      outputBinding:
        glob: "$(inputs.bamroot)_genome_flagstat.txt"
    anno_flagstat:
      type: File
      outputBinding:
        glob: "$(inputs.bamroot)_anno_flagstat.txt"
    log:
      type: File
      outputBinding:
        glob: "$(inputs.bamroot)_Log.final.out"
    genome_flagstat_json:
      type: File
      outputBinding:
        glob: "$(inputs.bamroot)_genome_flagstat.json"
    anno_flagstat_json:
      type: File
      outputBinding:
        glob: "$(inputs.bamroot)_anno_flagstat.json"
    log_json:
      type: File
      outputBinding:
        glob: "$(inputs.bamroot)_Log.final.json"
    python_log:
      type: File
      outputBinding:
        glob: "align.log"
