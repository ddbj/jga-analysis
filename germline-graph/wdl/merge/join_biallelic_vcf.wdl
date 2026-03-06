version 1.0

task JoinBiallelicVcf {
  parameter_meta {
    ref_fa_fai: "ref_fa and ref_fa_fai should be placed in the same directory"
  }

  input {
    File vcf
    File? ref_fa
    File? ref_fa_fai
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
