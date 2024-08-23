#!/usr/bin/env cwl-runner

class: CommandLineTool
id: rnaseq_align_SE
label: align
cwlVersion: v1.2

requirements:
  ResourceRequirement:
    ramMin: 4096
    coresMin: 8
  DockerRequirement:
    dockerPull: encodedcc/rna-seq-pipeline:1.2.4
baseCommand: [python3, /software/rna-seq-pipeline/src/align.py]

inputs:
  fastqs_R1:
    type: File[]
    inputBinding:
      position: 1
      prefix: "--fastqs_R1"
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
