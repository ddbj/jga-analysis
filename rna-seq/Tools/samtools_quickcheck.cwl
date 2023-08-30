#!/usr/bin/env cwl-runner

class: CommandLineTool
id: rnaseq_samtools_quickcheck
label: samtools_quickcheck
cwlVersion: v1.2

requirements:
  ResourceRequirement:
    ramMin: 64
    coresMin: 16
  DockerRequirement:
    dockerPull: docker://encodedcc/rna-seq-pipeline:1.2.4

baseCommand: [samtools, quickcheck]

inputs:
  genomebam:
    type: File
    inputBinding:
      position: 1
  ncpus:
    type: int
  ramGB:
    type: int
  disks:  
    type: string?
    default: "local-disk 100 SSD"

outputs: []
  # `samtools quickcheck`は主にエラーを返すか正常終了するかのみを行うため、具体的なファイル出力は定義しません。

# outputs:
#   output:
#     type: stdout

# stdout: samtools_quickcheck.log
# stdout: "stdout.log"
# stderr: "stderr.log"

# outputs:
#   tool_stdout:
#     type: File
#     outputBinding:
#       glob: "stdout.log"
#   tool_stderr:
#     type: File
#     outputBinding:
#       glob: "stderr.log"