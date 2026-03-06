version 1.0

task JoinBiallelicVcf {
  input {
    File vcf
    File? ref_fa
  }

  String join_filename = '~{basename(vcf, ".vcf")}.join.vcf'

  command <<<
    bcftools norm \
      ~{vcf} \
      -m+any \
      ~{if defined(ref_fa) then '-f ~{ref_fa}' else ''} \
      > ~{join_filename}
  >>>

  output {
    File join_vcf = join_filename
  }

  runtime {
    cpu: 1
    memory: "8 GB"
    docker: "quay.io/biocontainers/bcftools:1.23--h3a4d415_0"
  }
}
