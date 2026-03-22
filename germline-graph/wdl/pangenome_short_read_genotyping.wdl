version 1.0

# NOTE:
# This workflow supposes the existence of /tmp directory on all the nodes,
# and /tmp should be a fast, local file system.

import "kmer_count.wdl"
import "extract_reference_paths.wdl" as refpath
import "vg_giraffe.wdl" as giraffe
import "gam_to_sorted_bam.wdl" as bam
import "deepvariant.wdl" as dv
import "vg_sv_call.wdl" as sv

workflow PangenomeShortReadGenotyping {
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
    genotype_snarls: "[vg call] genotype every snarl, including reference calls"
    all_snarls: "[vg call] genotype all snarls, including nested child snarls"
    original_gbz: "[vg pack, vg call] perform genotyping using the pangenome GBZ, not the sampled GBZ"
    sampled_genotypes: "[vg call] restrict genotypes to the sampled haplotypes"
    snarls: "[vg call] snarls computed by vg snarls (to avoid recomputing)"
    min_snarl_length: "[vg call] genotype only snarls where at least one traversal has length >= this value"
    max_snarl_length: "[vg call] genotype only snarls where all traversals have length <= this value"
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
    Boolean original_gbz = false
    Boolean sampled_genotypes = true
    File? snarls
    Int? min_snarl_length
    Int? max_snarl_length
  }

  call kmer_count.KmerCount {
    input:
    read1_fq = read1_fq,
    read2_fq = read2_fq
  }

  call refpath.ExtractReferencePaths {
    input:
    gbz = gbz,
    ref_name = ref_name
  }

  call giraffe.VgGiraffe {
    input:
    sample_name = sample_name,
    gbz = gbz,
    hapl = hapl,
    read1_fq = read1_fq,
    read2_fq = read2_fq,
    kff = KmerCount.kff,
    diploid_sampling = true
  }

  call bam.GamToSortedBam {
    input:
    gam = VgGiraffe.gam,
    ref_name = ref_name,
    ref_path = ExtractReferencePaths.ref_path,
    gbz = VgGiraffe.sampled_gbz
  }

  call dv.Deepvariant {
    input:
    bam = GamToSortedBam.bam,
    bam_bai = GamToSortedBam.bam_bai,
    ref_fa = ref_fa,
    ref_fa_fai = ref_fa_fai
  }

  File genotyping_gbz = if original_gbz then gbz else VgGiraffe.sampled_gbz

  call sv.VgPack {
    input:
    gam = VgGiraffe.gam,
    gbz = genotyping_gbz
  }

  if (original_gbz && sampled_genotypes) {
    call sv.VgGbwt as SampledGbwt {
      input:
      gbz = VgGiraffe.sampled_gbz
    }
  }

  call sv.VgCall {
    input:
    sample_name = sample_name,
    pack = VgPack.pack,
    ref_name = ref_name,
    gbz = genotyping_gbz,
    gbwt = SampledGbwt.gbwt,
    genotype_snarls = genotype_snarls,
    all_snarls = all_snarls,
    snarls = snarls,
    min_snarl_length = min_snarl_length,
    max_snarl_length = max_snarl_length
  }

  output {
    File sampled_gbz = VgGiraffe.sampled_gbz
    File gam = VgGiraffe.gam
    File deepvariant_vcf_gz = Deepvariant.vcf_gz
    File deepvariant_vcf_gz_tbi = Deepvariant.vcf_gz_tbi
    File deepvariant_gvcf_gz = Deepvariant.gvcf_gz
    File deepvariant_gvcf_gz_tbi = Deepvariant.gvcf_gz_tbi
    File vg_call_vcf_gz = VgCall.vcf_gz
    File vg_call_vcf_gz_tbi = VgCall.vcf_gz_tbi
  }
}
