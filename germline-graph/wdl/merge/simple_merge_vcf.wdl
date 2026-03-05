version 1.0

import "bcftools_merge.wdl" as merge
import "reheader_vcf.wdl" as reheader
import "split_to_biallelic_vcf.wdl" as split
import "sort_vcf.wdl" as sort

workflow SimpleMergeVcf {
  meta {
    authors: ["Takeshi Fujino"]
  }

  input {
    Array[File] vcf_gz_list
    String ref_name = "GRCh38"
    File ref_fa
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

  call split.SplitToBiallelicVcf {
    input:
    vcf = ReheaderVcf.reheader_vcf,
    ref_fa = ref_fa
  }

  call sort.SortVcf {
    input:
    vcf = SplitToBiallelicVcf.split_vcf,
    out_prefix = out_prefix
  }

  output {
    File merge_vcf_gz = SortVcf.sort_vcf_gz
    File merge_vcf_gz_tbi = SortVcf.sort_vcf_gz_tbi
  }
}
