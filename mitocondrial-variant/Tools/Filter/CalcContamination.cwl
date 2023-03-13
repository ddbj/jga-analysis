#!/usr/bin/env cwl-runner

class: ExpressionTool
id: CalcContamination
label: CalcContamination
cwlVersion: v1.1

requirements:
  InlineJavascriptRequirement: {}

inputs:
  run_contamination:
    type: boolean
  hasContamination:
    type: string?
  # Although `contamination_major` and `contamination_major` are optional,
  # they should be filled when `run_contamination` is true and `hasContamination` is "YES"
  contamination_major:
    type: float?
  contamination_minor:
    type: float?
  verifyBamID:
    type: float?

outputs:
  hc_contamination:
    type: float
  max_contamination:
    type: float

expression: |
  ${
    var hc_contamination;
    if (inputs.run_contamination && inputs.hasContamination == "YES") {
      hc_contamination = inputs.contamination_major == 0.0 ? inputs.contamination_minor : 1.0 - inputs.contamination_major;
    } else {
      hc_contamination = 0.0
    };
    var max_contamination = (inputs.verifyBamID !== null && inputs.verifyBamID > hc_contamination) ? inputs.verifyBamID : hc_contamination;
    return {"hc_contamination": hc_contamination, "max_contamination":  max_contamination};
  }
