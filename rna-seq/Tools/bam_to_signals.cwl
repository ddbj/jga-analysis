#!/usr/bin/env cwl-runner

class: CommandLineTool
id: rnaseq_bam_to_signals
label: bam_to_signals
cwlVersion: v1.2

requirements:
  ResourceRequirement:
    ramMin: 2048
    coresMin: 8
  DockerRequirement:
    dockerPull: encodedcc/rna-seq-pipeline:1.2.4
  InlineJavascriptRequirement: {}

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
      glob: "*.genome_uniq.bw"
      outputEval: |
        ${
          if (inputs.strandedness === "unstranded" && self[0]) {
            return self[0];
          } else {
            return null;
          }
        }
  all_unstranded:
    type: File?
    outputBinding:
      glob: "*.genome_all.bw"
      outputEval: |
        ${
          if (inputs.strandedness === "unstranded" && self[0]) {
            return self[0];
          } else {
            return null;
          }
        }
  unique_plus:
    type: File?
    outputBinding:
      glob: "*.genome_plusUniq.bw"
      outputEval: |
        ${
          if (inputs.strandedness === "stranded" && self[0]) {
            return self[0];
          } else {
            return null;
          }
        }
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
      glob: "*.genome_plusAll.bw"
      outputEval: |
        ${
          if (inputs.strandedness === "stranded" && self[0]) {
            return self[0];
          } else {
            return null;
          }
        }
  all_minus:
    type: File?
    outputBinding:
      glob: "*.genome_minusAll.bw"
      outputEval: |
        ${
          if (inputs.strandedness === "stranded" && self[0]) {
            return self[0];
          } else {
            return null;
          }
        }
  python_log:
    type: File
    outputBinding:
      glob: "bam_to_signals.log"