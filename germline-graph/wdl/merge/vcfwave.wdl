version 1.0

# TODO: more sophisticated regex pattern match

task Vcfwave {
  input {
    File vcf
    Int? inv_min
  }

  String wave_filename = '~{basename(vcf, ".vcf")}.wave.vcf'

  command <<<
    # Output from vcfwave is not compliant with VCF specification and need to be fixed

    /usr/bin/time -v \
      vcfwave \
        ~{if defined(inv_min) then '-I ~{inv_min}' else ''} \
        --quiet | \
      sed -e 's/^##INFO=<ID=AT,Number=R/##INFO=<ID=AT,Number=./' | \
      awk 'BEGIN { OFS = "\t" } { sub(/INV=YES/, "INV", $8) } 1' \
      > ~{wave_filename}
  >>>

  output {
    File wave_vcf = wave_filename
  }

  runtime {
    cpu: 1
    memory: "32 GB"
    docker: "docker pull ghcr.io/tafujino/vcflib:8b5d4c81"
  }
}
