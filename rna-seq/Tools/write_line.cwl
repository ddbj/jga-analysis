#!/usr/bin/env cwl-runner

class: CommandLineTool
id: write_line_from_files
label: rsem_aggregate_from_files
cwlVersion: v1.2

requirements:
  InlineJavascriptRequirement: {}

baseCommand: bash
arguments:
  - -c
  - |
    echo -e "$(inputs.file_list.map(f => f.path).join('\n'))" > write_line.txt

inputs:
  file_list:
    type: File[]
    inputBinding:
      position: 1

outputs:
  write_line_file:
    type: File
    outputBinding:
      glob: write_line.txt


# class: CommandLineTool
# id: write_line
# label: rsem_aggregate
# cwlVersion: v1.2

# requirements:
#   InlineJavascriptRequirement: {}

# baseCommand: bash
# arguments:
#   - -c
#   - |
#     echo -e "$(inputs.file_list.join('\n'))" >  write_line.txt

# inputs:
#   file_list:
#     type: string[]
#     inputBinding:
#       position: 1

# outputs:
#   write_line_file:
#     type: File
#     outputBinding:
#       glob: write_line.txt