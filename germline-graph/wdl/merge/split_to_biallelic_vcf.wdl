version 1.0

task SplitToBiallelicVcf {
  input {
    File vcf
    File? ref_fa
    Boolean force = false
  }

  String split_filename = '~{basename(vcf, ".vcf")}.split.vcf'

  command <<<
    bcftools norm \
      ~{vcf} \
      -m-any \
      --multi-overlaps . \
      ~{if defined(ref_fa) then '-f ~{ref_fa}' else ''} \
      ~{if force then '--force' else ''} \
      > ~{split_filename}
  >>>

  output {
    File split_vcf = split_filename
  }

  runtime {
    cpu: 1
    memory: "8 GB"
    docker: "quay.io/biocontainers/bcftools:1.23--h3a4d415_0"
  }
}
