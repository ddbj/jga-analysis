version 1.0

# Comment:
# Is it possible to apply write_lines to Array[File] instead of Array[String]?
# https://github.com/openwdl/wdl/blob/legacy/versions/1.0/SPEC.md#file-write_linesarraystring

task BcftoolsMerge {
  input {
    Array[File] vcf_gz_list
    Array[File] vcf_gz_tbi_list
    String out_prefix = "merge"
    Boolean force_single = false
  }

  String merge_filename = "~{out_prefix}.vcf"

  command <<<
    bcftools merge \
    -m all \
    -l ~{write_lines(vcf_gz_list)} \
    ~{if defined(force_single) then '--force-single' else ''} \
    > ~{merge_filename}
  >>>

  output {
    File merge_vcf = merge_filename
  }

  runtime {
    cpu: 1
    memory: "8 GB"
    docker: "quay.io/biocontainers/bcftools:1.23--h3a4d415_0"
  }
}
