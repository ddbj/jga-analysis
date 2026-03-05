version 1.0

################################################################################
# task VgGbwt

# Comment:
# Resource usage should be optimized

task VgGbwt {
  input {
    File gbz
  }

  String gbwt_filename = '~{basename(gbz, ".gbz")}.gbwt'

  command <<<
    /usr/bin/time -v \
      vg gbwt \
        ~{gbz} \
        --gbz-input \
        -o ~{gbwt_filename}
  >>>

  output {
    File gbwt = gbwt_filename
  }

  runtime {
    cpu: 1
    memory: "16 GB"
    docker: "quay.io/vgteam/vg:v1.68.0"
  }
}

################################################################################
# task VgPack

# Comment:
# reduce memory size and # of threads?

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
    memory: "96 GB"
    docker: "quay.io/vgteam/vg:v1.68.0"
  }
}

################################################################################
# task VgCall

task VgCall {
  # TODO: add more descriptions
  parameter_meta {
    genotype_snarls: "if true, genotype every snarl, including reference calls"
    all_snarls: "if true, genotype all snarls, including nested child snarls"
    snarls: "snarls computed by vg snarls (to avoid recomputing)"
    min_snarl_length: "genotype only snarls where at least one traversal has length >= this value"
    max_snarl_length: "genotype only snarls where all traversals have length <= this value"
  }

  input {
    String sample_name
    File pack
    String ref_name
    File gbz
    File? gbwt
    Boolean genotype_snarls = false
    Boolean all_snarls = false
    File? snarls
    Int? min_snarl_length
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
        ~{if defined(gbwt) then '--gbwt ~{gbwt}' else '--gbz'} \
        ~{if genotype_snarls then '--genotype-snarls' else ''} \
        ~{if all_snarls then '--all-snarls' else ''} \
        ~{if defined(snarls) then '--snarls ~{snarls}' else ''} \
        ~{if defined(min_snarl_length) then '--min-length ~{min_snarl_length}' else ''} \
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
