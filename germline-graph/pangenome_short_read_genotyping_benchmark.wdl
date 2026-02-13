version 1.0

import "pangenome_short_read_genotyping.wdl" as genotyping
import "happy.wdl"
import "truvari.wdl"

workflow PangenomeShortReadGenotypingBenchmark {
  meta {
    authors: ["Takeshi Fujino"]
  }

  parameter_meta {
    read1_fq: "read1 FASTQ (maybe gzipped) of paired-end sequencing"
    read2_fq: "read2 FASTQ (maybe gzipped) of paired-end sequencing"
    ref_name: "reference name in the pangenome"
    ref_fa: "reference FASTA"
    ref_fa_fai: "reference FASTA index"
    gbz: "pangenome in GBZ format"
    hapl: "pangenome haplotype index"
    genotype_snarls: "[vg call] if true, genotype every snarl, including reference calls"
    all_snarls: "[vg call] if true, genotype all snarls, including nested child snarls"
    snarls: "[vg call] snarls computed by vg snarls"
    min_snarl_length: "[vg call] genotype only snarls where at least one traversal has length >= this value"
    max_snarl_length: "[vg call] genotype only snarls where all traversals have length <= this value"
    evaluate_sv: "if true, compare SV genotypes with the benchmark"
    sv_benchmark_vcf_gz: "required if evaluate_sv is true"
    sv_benchmark_vcf_gz_tbi: "required if evaluate_sv is true"
    sv_benchmark_bed: "required if evaluate_sv is true"
  }

  input {
    String sample_name
    File read1_fq
    File read2_fq
    String ref_name = "GRCh38"
    File ref_fa
    File ref_fa_fai
    File gbz
    File? hapl
    Boolean genotype_snarls = false
    Boolean all_snarls = false
    Boolean call_sampled_genotypes = true
    File? snarls
    Int? min_snarl_length
    Int? max_snarl_length
    File small_var_benchmark_vcf_gz
    File small_var_benchmark_vcf_gz_tbi
    File small_var_benchmark_bed
    Boolean evaluate_sv = true
    File? sv_benchmark_vcf_gz
    File? sv_benchmark_vcf_gz_tbi
    File? sv_benchmark_bed
  }

  call genotyping.PangenomeShortReadGenotyping as Gt {
    input:
    sample_name = sample_name,
    read1_fq = read1_fq,
    read2_fq = read2_fq,
    ref_name = ref_name,
    ref_fa = ref_fa,
    ref_fa_fai = ref_fa_fai,
    gbz = gbz,
    hapl = hapl,
    genotype_snarls = genotype_snarls,
    all_snarls = all_snarls,
    call_sampled_genotypes = call_sampled_genotypes,
    snarls = snarls,
    min_snarl_length = min_snarl_length,
    max_snarl_length = max_snarl_length
  }

  call happy.Happy {
    input:
    comparison_vcf_gz = Gt.deepvariant_vcf_gz,
    comparison_vcf_gz_tbi = Gt.deepvariant_vcf_gz_tbi,
    baseline_vcf_gz = small_var_benchmark_vcf_gz,
    baseline_vcf_gz_tbi = small_var_benchmark_vcf_gz_tbi,
    baseline_bed = small_var_benchmark_bed,
    ref_fa = ref_fa,
    ref_fa_fai = ref_fa_fai
  }

  if (evaluate_sv) {
    call truvari.TruvariBench {
      input:
      comparison_vcf_gz = Gt.vg_call_vcf_gz,
      comparison_vcf_gz_tbi = Gt.vg_call_vcf_gz_tbi,
      baseline_vcf_gz = select_first([sv_benchmark_vcf_gz]),
      baseline_vcf_gz_tbi = select_first([sv_benchmark_vcf_gz_tbi]),
      baseline_bed = select_first([sv_benchmark_bed]),
      ref_fa = ref_fa
    }
  }

  output {
    File deepvariant_vcf_gz = Gt.deepvariant_vcf_gz
    File deepvariant_vcf_gz_tbi = Gt.deepvariant_vcf_gz_tbi
    File deepvariant_gvcf_gz = Gt.deepvariant_gvcf_gz
    File deepvariant_gvcf_gz_tbi = Gt.deepvariant_gvcf_gz_tbi
    File vg_call_vcf_gz = Gt.vg_call_vcf_gz
    File vg_call_vcf_gz_tbi = Gt.vg_call_vcf_gz_tbi
    File happy_summary = Happy.summary
    File? truvari_summary = TruvariBench.summary
  }
}
