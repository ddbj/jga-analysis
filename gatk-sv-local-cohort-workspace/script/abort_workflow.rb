# frozen_string_literal: true

require 'json'
require 'optparse'
require_relative 'lib/cromwell_server'
require_relative 'lib/settings'

opt = OptionParser.new
opt.banner = "Usage: #{$PROGRAM_NAME} SUBMISSION_ID..."
opt.parse!(ARGV)

cromwell_network_conf = JSON.parse(File.read(CROMWELL_NETWORK_CONF_PATH))
cromwell = CromwellServer.new(cromwell_network_conf['ip'],
                              cromwell_network_conf['port'])

ARGV.each do |submission_id|
  cromwell.abort(submission_id)
end
