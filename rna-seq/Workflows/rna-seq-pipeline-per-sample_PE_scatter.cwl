#!/usr/bin/env cwl-runner

class: Workflow
id: rna-seq-pipeline-per-sample_PE_scatter
label: rna-per-sample_PE_scatter
cwlVersion: v1.2

requirements:
  InlineJavascriptRequirement: {}
  SubworkflowFeatureRequirement: {}
  ScatterFeatureRequirement: {}
  StepInputExpressionRequirement: {}

inputs:
  sample_list:
    type:
      type: array
      items:
        - type: record
          fields:
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

steps:
  align:
    run: ../Tools/align_PE.cwl
    in:
      sample_list: sample_list
      fastqs_R1: 
        valueFrom: $(inputs.sample_list.fastqs_R1)
      fastqs_R2: 
        valueFrom: $(inputs.sample_list.fastqs_R2)
      endedness: 
        valueFrom: $(inputs.sample_list.endedness)
      index: 
        valueFrom: $(inputs.sample_list.index)
      bamroot: 
        valueFrom: $(inputs.sample_list.bamroot)
      ncpus: 
        valueFrom: $(inputs.sample_list.ncpus)
      ramGB: 
        valueFrom: $(inputs.sample_list.ramGB)
    scatter:
      - sample_list
    scatterMethod: dotproduct
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
    # out: [genomebam, annobam, genome_flagstat, anno_flagstat, log, genome_flagstat_json, anno_flagstat_json, log_json, python_log]
  samtools_quickcheck_genome:
    run: ../Tools/samtools_quickcheck.cwl
    in:
      bam: align/genomebam
      ncpus: { default: 1 }
      ramGB: { default: 2 }
      disks: { default: "local-disk 20 SSD" }
    scatter:
      - bam
    scatterMethod: dotproduct
    out: []
  samtools_quickcheck_anno:
    run: ../Tools/samtools_quickcheck.cwl
    in:
      bam: align/annobam
      ncpus: { default: 1 }
      ramGB: { default: 2 }
      disks: { default: "local-disk 20 SSD" }
    scatter:
      - bam
    scatterMethod: dotproduct
    out: []
  bam_to_signals:
    run: ../Tools/bam_to_signals.cwl
    in:
      sample_list: sample_list
      input_bam: align/genomebam
      # input_bam: 
      #   valueFrom: $(steps.align.out.genomebam)
      chrom_sizes: 
        valueFrom: $(inputs.sample_list.chrom_sizes)
      strandedness: 
        valueFrom: $(inputs.sample_list.strandedness)
      bamroot:
        valueFrom: $(inputs.sample_list.bamroot)_genome
        # source: bamroot
        # valueFrom: $(self)_genome
      ncpus: 
        valueFrom: $(inputs.sample_list.ncpus)
      ramGB: 
        valueFrom: $(inputs.sample_list.ramGB)
      disks: { default: "local-disk 20 HDD" }
    scatter:
      - sample_list
      - input_bam
    scatterMethod: dotproduct
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
      sample_list: sample_list
      rsem_index: 
        valueFrom: $(inputs.sample_list.rsem_index)
      anno_bam: align/annobam
      # anno_bam: 
      #   valueFrom: $(steps.align.out.annobam)
      endedness: 
        valueFrom: $(inputs.sample_list.endedness)
      read_strand: 
        valueFrom: $(inputs.sample_list.read_strand)
      rnd_seed: 
        valueFrom: $(inputs.sample_list.rnd_seed)
      ncpus: 
        valueFrom: $(inputs.sample_list.ncpus)
      ramGB: 
        valueFrom: $(inputs.sample_list.ramGB)
      disks: { default: "local-disk 20 HDD" }
    scatter:
      - sample_list
      - anno_bam
    scatterMethod: dotproduct
    out:
      - genes_results
      - isoforms_results
      - number_of_genes
      - python_log
  rna_qc:
    run: ../Tools/rna_qc.cwl
    in:
      sample_list: sample_list
      input_bam: align/annobam
      tr_id_to_gene_type_tsv: tr_id_to_gene_type_tsv
      output_filename: 
        valueFrom: $(inputs.sample_list.bamroot)_qc.json
        # source: bamroot
        # valueFrom: $(self)_qc.json
      disks: { default: "local-disk 20 HDD" }
    scatter:
      - sample_list
      - input_bam
    scatterMethod: dotproduct
    out:
      - rnaQC
      - python_log
# steps:
#   align:
#     run: ../Tools/align_PE.cwl
#     in:
#       fastqs_R1: fastqs_R1
#       fastqs_R2: fastqs_R2
#       endedness: endedness
#       index: index
#       bamroot: bamroot
#       ncpus: ncpus
#       ramGB: ramGB
#     out:
#       - genomebam
#       - annobam
#       - genome_flagstat
#       - anno_flagstat
#       - log
#       - genome_flagstat_json
#       - anno_flagstat_json
#       - log_json
#       - python_log
#   samtools_quickcheck_genome:
#     run: ../Tools/samtools_quickcheck.cwl
#     in:
#       bam: align/genomebam
#       ncpus: { default: 1 }
#       ramGB: { default: 2 }
#       disks: { default: "local-disk 20 SSD" }
#     out: []
#   samtools_quickcheck_anno:
#     run: ../Tools/samtools_quickcheck.cwl
#     in:
#       bam: align/annobam
#       ncpus: { default: 1 }
#       ramGB: { default: 2 }
#       disks: { default: "local-disk 20 SSD" }
#     out: []
#   bam_to_signals:
#     run: ../Tools/bam_to_signals.cwl
#     in:
#       input_bam: align/genomebam
#       chrom_sizes: chrom_sizes
#       strandedness: strandedness
#       bamroot:
#         source: bamroot
#         valueFrom: $(self)_genome
#       ncpus: ncpus
#       ramGB: ramGB
#       disks: { default: "local-disk 20 HDD" }
#     out:
#       - unique_unstranded
#       - all_unstranded
#       - unique_plus
#       - unique_minus
#       - all_plus
#       - all_minus
#       - python_log
#   rsem_quant:
#     run: ../Tools/rsem_quant.cwl
#     in:
#       rsem_index: rsem_index
#       anno_bam: align/annobam
#       endedness: endedness
#       read_strand: read_strand
#       rnd_seed: rnd_seed
#       ncpus: ncpus
#       ramGB: ramGB
#       disks: { default: "local-disk 20 HDD" }
#     out:
#       - genes_results
#       - isoforms_results
#       - number_of_genes
#       - python_log
#   rna_qc:
#     run: ../Tools/rna_qc.cwl
#     in:
#       input_bam: align/annobam
#       tr_id_to_gene_type_tsv: tr_id_to_gene_type_tsv
#       output_filename: 
#         source: bamroot
#         valueFrom: $(self)_qc.json
#       disks: { default: "local-disk 20 HDD" }
#     out:
#       - rnaQC
#       - python_log

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