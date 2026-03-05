version 1.0

# Comment:
# More strict regex match

task ReheaderVcf {
  input {
    File vcf
    String ref_name
  }

  String reheader_filename = '~{basename(vcf, ".vcf")}.reheader.vcf'

  command <<<
    sed -e "s/~{ref_name}#0#//" ~{vcf} > ~{reheader_filename}
  >>>

  output {
    File reheader_vcf = reheader_filename
  }

  runtime {
    cpu: 1
    memory: "8 GB"
    docker: "ubuntu:26.04"
  }
}
