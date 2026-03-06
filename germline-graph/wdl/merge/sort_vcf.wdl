version 1.0

task SortVcf {
  input {
    File vcf
    String out_prefix
  }

  command <<<
    bcftools sort ~{vcf} -O z --write-index -o ~{out_prefix}.vcf.gz
  >>>

  output {
    File sort_vcf_gz = "~{out_prefix}.vcf.gz"
    File sort_vcf_gz_tbi = "~{out_prefix}.vcf.gz.tbi"
  }

  runtime {
    cpu: 1
    memory: "8 GB"
    docker: "quay.io/biocontainers/bcftools:1.23--h3a4d415_0"
  }
}
