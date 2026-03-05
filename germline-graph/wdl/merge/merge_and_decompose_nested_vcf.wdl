version 1.0

import "bcftools_merge.wdl" as merge
import "join_biallelic_vcf.wdl" as join
import "sort_vcf.wdl" as sort
import "split_to_biallelic_vcf.wdl" as split
import "reheader_vcf.wdl" as reheader
import "vcfbub.wdl" as bub
import "vcfwave.wdl" as wave

workflow MergeAndDecomposeNestedVcf {
  meta {
    authors: ["Takeshi Fujino"]
  }

  input {
    Array[File] vcf_gz_list
    String ref_name = "GRCh38"
    File ref_fa
    Int max_allele_length = 100000
    Int inv_min = 1000
    String out_prefix
  }

  call merge.BcftoolsMerge {
    input:
    vcf_gz_list = vcf_gz_list,
  }

  call reheader.ReheaderVcf {
    input:
    vcf = BcftoolsMerge.merge_vcf,
    ref_name = ref_name
  }

  call bub.Vcfbub {
    input:
    vcf = ReheaderVcf.reheader_vcf,
    max_level = 0,
    max_allele_length = max_allele_length
  }

  call split.SplitToBiallelicVcf as split1 {
    input:
    vcf = Vcfbub.bub_vcf
  }

  call wave.Vcfwave {
    input:
    vcf = split1.split_vcf,
    inv_min = inv_min
  }

  call join.JoinBiallelicVcf {
    input:
    vcf = Vcfwave.wave_vcf,
    ref_fa = ref_fa
  }

  call split.SplitToBiallelicVcf as split2 {
    input:
    vcf = JoinBiallelicVcf.join_vcf,
    force = true
  }

  call sort.SortVcf {
    input:
    vcf = split2.split_vcf,
    out_prefix = out_prefix
  }

  output {
    File merge_vcf_gz = SortVcf.sort_vcf_gz
    File merge_vcf_gz_tbi = SortVcf.sort_vcf_gz_tbi
  }
}
