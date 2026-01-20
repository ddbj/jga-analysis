version 1.0

################################################################################
# task VgPack

task VgPack {
  input {
    File gam
    File gbz
    Int min_mapq = 5
    Int num_cpus = 32
  }

  String pack_filename = '~{basename(gam, ".gam")}.pack'

  command <<<
    /usr/bin/time -v \
      vg pack \
        -x ~{gbz} \
        -g ~{gam} \
        -Q ~{min_mapq} \
        -t ~{num_cpus} \
        -o ~{pack_filename}
  >>>

  output {
    File pack = pack_filename
  }

  runtime {
    cpu: num_cpus
    memory: "64 GB"
    docker: "quay.io/vgteam/vg:v1.68.0"
  }
}

################################################################################
# task VgCall

# Comment:
# Pre-calculation of snarls and using `vg call -r [snarls]` may accelerate the compuation

task VgCall {
  parameter_meta {
    max_snarl_length: "if specified, genotype only snarls where all traversals have length <= this value"
  }

  input {
    String sample_name
    File pack
    String ref_name
    File gbz
    Int? max_snarl_length
    Int num_cpus = 16
  }

  String vcf_basename = basename(pack, ".pack")

  command <<<
    /usr/bin/time -v \
      vg call \
        ~{gbz} \
        --sample ~{sample_name} \
        --pack ~{pack} \
        --ref-sample ~{ref_name} \
        --gbz \
        --genotype-snarls \
        ~{if defined(max_snarl_length) then '--max-length ~{max_snarl_length}' else ''} \
        -t ~{num_cpus} \
        > ~{vcf_basename}.vcf

    bgzip ~{vcf_basename}.vcf
    tabix -p vcf ~{vcf_basename}.vcf.gz
  >>>

  output {
    File vcf_gz = "~{vcf_basename}.vcf.gz"
    File vcf_gz_tbi = "~{vcf_basename}.vcf.gz.tbi"
  }

  runtime {
    cpu: num_cpus
    memory: "128 GB"
    docker: "quay.io/vgteam/vg:v1.68.0"
  }
}
