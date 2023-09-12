#!/usr/bin/env cwl-runner

class: Workflow
id: rna-seq-pipeline-per-sample_PE
label: rna-per-sample_PE
cwlVersion: v1.2

requirements:
  StepInputExpressionRequirement: {}

inputs:
  fastqs_R1:
    type: File[]
  fastqs_R2:
    type: File[]
  endedness:
    type: string
  index:
    type: File
  bamroot:
    type: string
  ncpus:
    type: int
  ramGB:
    type: int
  chrom_sizes:
    type: File
  strandedness: 
    type: string 
  rsem_index:
    type: File
  read_strand:
    type: string
  rnd_seed:
    type: int
  tr_id_to_gene_type_tsv:
    type: File
# endednessの値がpairedか、singleかでstepsのrunで実行するcwlファイルを変えたい

steps:
  align:
    run: ../Tools/align_PE.cwl
    in:
      fastqs_R1: fastqs_R1
      fastqs_R2: fastqs_R2
      endedness: endedness
      index: index
      bamroot: bamroot
      ncpus: ncpus
      ramGB: ramGB
    out:
      - genomebam
      - annobam
      - genome_flagstat
      - anno_flagstat
      - log
      - genome_flagstat_json
      - anno_flagstat_json
      - log_json
      - python_log
  samtools_quickcheck_genome:
    run: ../Tools/samtools_quickcheck.cwl
    in:
      bam: align/genomebam
      ncpus: { default: 1 }
      ramGB: { default: 2 }
      disks: { default: "local-disk 20 SSD" }
    out: []
  samtools_quickcheck_anno:
    run: ../Tools/samtools_quickcheck.cwl
    in:
      bam: align/annobam
      ncpus: { default: 1 }
      ramGB: { default: 2 }
      disks: { default: "local-disk 20 SSD" }
    out: []
  bam_to_signals:
    run: ../Tools/bam_to_signals.cwl
    in:
      input_bam: align/genomebam
      chrom_sizes: chrom_sizes
      strandedness: strandedness
      bamroot:
        source: bamroot
        valueFrom: $(self)_genome
      ncpus: ncpus
      ramGB: ramGB
      disks: { default: "local-disk 20 HDD" }
    out:
      - unique_unstranded
      - all_unstranded
      - unique_plus
      - unique_minus
      - all_plus
      - all_minus
      - python_log
  rsem_quant:
    run: ../Tools/rsem_quant.cwl
    in:
      rsem_index: rsem_index
      anno_bam: align/annobam
      endedness: endedness
      read_strand: read_strand
      rnd_seed: rnd_seed
      ncpus: ncpus
      ramGB: ramGB
      disks: { default: "local-disk 20 HDD" }
    out:
      - genes_results
      - isoforms_results
      - number_of_genes
      - python_log
  rna_qc:
    run: ../Tools/rna_qc.cwl
    in:
      input_bam: align/annobam
      tr_id_to_gene_type_tsv: tr_id_to_gene_type_tsv
      output_filename: 
        source: bamroot
        valueFrom: $(self)_qc.json
      disks: { default: "local-disk 20 HDD" }
    out:
      - rnaQC
      - python_log
outputs:
  genomebam:
    type: File
    outputSource: align/genomebam
  annobam:
    type: File
    outputSource: align/annobam
  genome_flagstat:
    type: File
    outputSource: align/genome_flagstat
  anno_flagstat:
    type: File
    outputSource: align/anno_flagstat
  log:
    type: File
    outputSource: align/log
  genome_flagstat_json:
    type: File
    outputSource: align/genome_flagstat_json
  anno_flagstat_json:
    type: File
    outputSource: align/anno_flagstat_json
  log_json:
    type: File
    outputSource: align/log_json
  python_log:
    type: File
    outputSource: align/python_log
  unique_unstranded:
    type: File?
    outputSource: bam_to_signals/unique_unstranded
  all_unstranded:
    type: File?
    outputSource: bam_to_signals/all_unstranded
  unique_plus:
    type: File?
    outputSource: bam_to_signals/unique_plus
  unique_minus:
    type: File?
    outputSource: bam_to_signals/unique_minus
  all_plus:
    type: File?
    outputSource: bam_to_signals/all_plus
  all_minus:
    type: File?
    outputSource: bam_to_signals/all_minus
  python_log_bts:
    type: File
    outputSource: bam_to_signals/python_log
  genes_results:
    type: File
    outputSource: rsem_quant/genes_results
  isoforms_results:
    type: File
    outputSource: rsem_quant/isoforms_results
  number_of_genes:
    type: File
    outputSource: rsem_quant/number_of_genes
  python_log_rsem:
    type: File
    outputSource: rsem_quant/python_log
  rnaQC:
    type: File
    outputSource: rna_qc/rnaQC
  python_log_rna_qc:
    type: File
    outputSource: rna_qc/python_log