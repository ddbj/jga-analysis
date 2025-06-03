# frozen_string_literal: true

require_relative 'lib/cromwell_server'
require_relative 'lib/settings'
require_relative 'lib/workspace'

cromwell_network_conf = JSON.parse(File.read(CROMWELL_NETWORK_CONF_PATH))
cromwell = CromwellServer.new(cromwell_network_conf['ip'],
                              cromwell_network_conf['port'])
workspace = Workspace.new(WORKSPACE_DIR, WORKFLOW_CONF_DIR, cromwell)
workspace.update_data
