# frozen_string_literal: true

require 'pathname'

GATK_SV_VERSION = 'v1.0.3'
CROMWELL_DIR = Pathname.new('cromwell')
CROMWELL_NETWORK_CONF_PATH = CROMWELL_DIR / 'network.json'
WORKSPACE_DIR = Pathname.new('workspace')
WORKFLOW_CONF_DIR = Pathname.new('workflow_configurations')
