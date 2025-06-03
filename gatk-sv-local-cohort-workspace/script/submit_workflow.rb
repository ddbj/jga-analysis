# frozen_string_literal: true

require 'optparse'
require 'stringio'
require_relative 'lib/cromwell_server'
require_relative 'lib/settings'
require_relative 'lib/workspace'

cromwell_network_conf = JSON.parse(File.read(CROMWELL_NETWORK_CONF_PATH))
cromwell = CromwellServer.new(cromwell_network_conf['ip'],
                              cromwell_network_conf['port'])
workspace = Workspace.new(WORKSPACE_DIR, WORKFLOW_CONF_DIR, cromwell)

sio = StringIO.new
sio.puts "Usage: #{$PROGRAM_NAME} WORKFLOW_NAME"
sio.puts
sio.puts 'Workflow name:'
workspace.workflows.each_value { |workflow| sio.puts "  #{workflow.name}" }
sio.puts

param = { read_from_cache: true, force_resubmit: false }
opt = OptionParser.new
opt.banner = sio.string
opt.on('-C', '--disable-cache') { param[:read_from_cache] = false }
opt.on('-f', '--force-resubmit') { param[:force_resubmit] = true }
opt.parse!(ARGV)

workflow_name = ARGV.shift

unless workflow_name
  puts opt.help
  exit 1
end

workspace.update_data
workspace.submit_workflow(workflow_name,
                          read_from_cache: param[:read_from_cache],
                          force_resubmit: param[:force_resubmit])
