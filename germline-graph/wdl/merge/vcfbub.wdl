version 1.0

task Vcfbub {
  input {
    File vcf
    Int? max_level
    Int? max_allele_length
  }

  String bub_filename = '~{basename(vcf, ".vcf")}.bub.vcf'

  command <<<
    /usr/bin/time -v \
      vcfbub \
        --input ~{vcf} \
        ~{if defined(max_level) then '-l {max_level}' else ''} \
        ~{if defined(max_allele_length) then '-a {max_allele_length}' else ''} \
        > ~{bub_filename}
  >>>

  output {
    File bub_vcf = bub_filename
  }

  runtime {
    cpu: 1
    memory: "16 GB"
    docker: "quay.io/biocontainers/vcfbub:0.1.2--hc1c3326_1"
  }
}
