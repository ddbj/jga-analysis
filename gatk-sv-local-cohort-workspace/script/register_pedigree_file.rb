# frozen_string_literal: true

require 'optparse'
require_relative 'lib/cromwell_server'
require_relative 'lib/settings'
require_relative 'lib/workspace'

opt = OptionParser.new
opt.banner = "Usage: #{$PROGRAM_NAME} PED_FILE"
opt.parse!(ARGV)

ped_path = ARGV.shift

unless ped_path
  puts opt.help
  exit 1
end

cromwell_network_conf = JSON.parse(File.read(CROMWELL_NETWORK_CONF_PATH))
cromwell = CromwellServer.new(cromwell_network_conf['ip'],
                              cromwell_network_conf['port'])
workspace = Workspace.new(WORKSPACE_DIR, WORKFLOW_CONF_DIR, cromwell)
workspace.register_pedigree_file(ped_path)
