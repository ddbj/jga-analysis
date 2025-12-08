version 1.0

task VgGiraffe {
  parameter_meta {
    hapl: "required if diploid_sampling is true"
    kff: "KMC output. required if diploid_sampling is true"
    sampled_gbz: "sampled GBZ if diploid_sampling is true; otherwise a dummy empty file"
  }

  input {
    String sample_name
    File gbz
    File? hapl
    File read1_fq
    File read2_fq
    File? kff
    Boolean diploid_sampling = true
    Int num_cpus = 32
  }

  String sampling_basename = basename(gbz, ".gbz")

  command <<<
    set -xe

    TMP_DIR=$(mktemp -d -p /tmp)
    INDEX_BASENAME="$TMP_DIR/~{sampling_basename}"

    cp ~{gbz} "$TMP_DIR"
    GBZ_PATH="$TMP_DIR/$(basename ~{gbz})"

    if ~{diploid_sampling}; then
      cp ~{hapl} "$TMP_DIR"
      HAPL_PATH="$TMP_DIR/$(basename ~{hapl})"
    fi

    /usr/bin/time -v \
      vg giraffe \
        --read-group "ID:1 LB:lib1 SM:~{sample_name} PL:illumina PU:unit1" \
        --sample ~{sample_name} \
        -f ~{read1_fq} \
        -f ~{read2_fq} \
        -Z "$GBZ_PATH" \
        ~{if diploid_sampling then '--kff-name ~{kff}' else ''} \
        ~{if diploid_sampling then '--haplotype-name "$HAPL_PATH"' else ''} \
        ~{if diploid_sampling then '--index-basename "$INDEX_BASENAME"' else ''} \
        -t ~{num_cpus} \
        > ~{sample_name}.gam

    SAMPLED_GBZ_PATH="$INDEX_BASENAME.~{sample_name}.gbz"
    if [ -f "$SAMPLED_GBZ_PATH" ]; then
      cp "$SAMPLED_GBZ_PATH" .
    else
      touch "$SAMPLED_GBZ_PATH"
    fi

    rm -rf "$TMP_DIR"
  >>>

  output {
    File gam = "~{sample_name}.gam"
    File sampled_gbz = "~{sampling_basename}.~{sample_name}.gbz"
  }

  runtime {
    cpu: num_cpus
    memory: "64 GB"
    docker: "quay.io/vgteam/vg:v1.68.0"
  }
}
