#!/usr/bin/env cwl-runner

class: CommandLineTool
id: rnaseq_bam_to_signals
label: bam_to_signals
cwlVersion: v1.2

requirements:
  ResourceRequirement:
    ramMin: 64
    coresMin: 16
  DockerRequirement:
    dockerPull: docker://encodedcc/rna-seq-pipeline:1.2.4

baseCommand: [python3, /software/rna-seq-pipeline/src/bam_to_signals.py]

inputs:
  input_bam:
    type: File
    inputBinding:
      position: 1
      prefix: "--bamfile"
  chrom_sizes:
    type: File
    inputBinding:
      position: 2
      prefix: "--chrom_sizes"
  strandedness:
    type: string
    inputBinding:
      position: 3
      prefix: "--strandedness"
  bamroot:
    type: string
    inputBinding:
      position: 4
      prefix: "--bamroot"
      # valueFrom: "${self}_genome"
  ncpus:
    type: int
  ramGB:
    type: int
  disks:  
    type: string?

outputs:
  unique_unstranded:
    type: File?
    outputBinding:
      glob: "$(if (inputs.strandedness == 'unstranded') then '*.genome_uniq.bw' else '')"
      outputEval: |
        '$(if (self.length > 0) {
          return self[0];
        } else {
          return null;
        })'

  all_unstranded:
    type: File?
    outputBinding:
      glob: "$(if (inputs.strandedness == 'unstranded') then '*.genome_all.bw' else '')"
      outputEval: |
        '$(if (self.length > 0) {
          return self[0];
        } else {
          return null;
        })'
  unique_plus:
    type: File?
    outputBinding:
      glob: "$(if (inputs.strandedness == 'stranded') then '*.genome_plusUniq.bw' else '')"
      outputEval: |
        '$(if (self.length > 0) {
          return self[0];
        } else {
          return null;
        })'
  unique_minus:
    type: File?
    outputBinding:
      glob: "*_genome_minusUniq.bw"
      outputEval: |
        ${
          if (inputs.strandedness === "stranded" && self[0]) {
            return self[0];
          } else {
            return null;
          }
        }

  all_plus:
    type: File?
    outputBinding:
      glob: "$(if (inputs.strandedness == 'stranded') then '*.genome_plusAll.bw' else '')"
      outputEval: |
        '$(if (self.length > 0) {
          return self[0];
        } else {
          return null;
        })'

  all_minus:
    type: File?
    outputBinding:
      glob: "$(if (inputs.strandedness == 'stranded') then '*.genome_minusAll.bw' else '')"
      outputEval: |
        '$(if (self.length > 0) {
          return self[0];
        } else {
          return null;
        })'
  python_log:
    type: File