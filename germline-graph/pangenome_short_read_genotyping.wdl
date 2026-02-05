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
    hapl: "pangenome haplotype index (required if diploid_sampling is true)"
    diploid_sampling: "if true, performs diploid sampling and maps reads to the sampled graph; otherwise maps reads to the original graph"
    genotype_snarls: "[vg call] if true, genotype every snarl, including reference calls"
    snarls: "[vg call] snarls computed by vg snarls"
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
    Boolean diploid_sampling = true
    Boolean genotype_snarls = true
    File? snarls
    Int? max_snarl_length # Comment: add default?
  }

  if (diploid_sampling) {
    call kmer_count.KmerCount {
      input:
      read1_fq = read1_fq,
      read2_fq = read2_fq
    }
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
    diploid_sampling = diploid_sampling
  }

  File sampled_gbz = if diploid_sampling then VgGiraffe.sampled_gbz else gbz

  call bam.GamToSortedBam {
    input:
    gam = VgGiraffe.gam,
    ref_name = ref_name,
    ref_path = ExtractReferencePaths.ref_path,
    gbz = sampled_gbz
  }

  call dv.Deepvariant {
    input:
    bam = GamToSortedBam.bam,
    bam_bai = GamToSortedBam.bam_bai,
    ref_fa = ref_fa,
    ref_fa_fai = ref_fa_fai
  }

  call sv.VgPack {
    input:
    gam = VgGiraffe.gam,
    gbz = gbz
  }

  call sv.VgGbwt as SampledGbwt {
    input:
    gbz = sampled_gbz
  }

  call sv.VgCall {
    input:
    sample_name = sample_name,
    pack = VgPack.pack,
    ref_name = ref_name,
    gbz = gbz,
    gbwt = SampledGbwt.gbwt,
    genotype_snarls = genotype_snarls,
    snarls = snarls,
    max_snarl_length = max_snarl_length
  }

  output {
    File deepvariant_vcf_gz = Deepvariant.vcf_gz
    File deepvariant_vcf_gz_tbi = Deepvariant.vcf_gz_tbi
    File deepvariant_gvcf_gz = Deepvariant.gvcf_gz
    File deepvariant_gvcf_gz_tbi = Deepvariant.gvcf_gz_tbi
    File vg_call_vcf_gz = VgCall.vcf_gz
    File vg_call_vcf_gz_tbi = VgCall.vcf_gz_tbi
  }
}
