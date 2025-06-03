# frozen_string_literal: true

require 'rest-client'
require 'json'

CROMWELL_API_VERSION = 'v1'

class CromwellServer
  # @param host [String]
  # @param port [Integer]
  def initialize(host, port)
    @host = host
    @port = port
    @uri_prefix = "http://#{@host}:#{@port}/api/workflows/#{CROMWELL_API_VERSION}"
  end

  # @param wdl_path [String]
  # @param deps_path [String] zip
  # @param inputs_path [String] json
  # @param options_path [String] json
  # @return [Hash]
  def submit(wdl_path, deps_path, inputs_path, options_path)
    wdl_file = File.open(wdl_path, 'rb')
    deps_file = File.open(deps_path, 'rb')
    inputs_file = File.open(inputs_path, 'rb')
    options_file = File.open(options_path, 'rb')
    res = RestClient.post(@uri_prefix,
                          { workflowType: 'WDL',
                            workflowSource: wdl_file,
                            workflowDependencies: deps_file,
                            workflowInputs: inputs_file,
                            workflowOptions: options_file })
    wdl_file.close
    deps_file.close
    inputs_file.close
    options_file.close
    JSON.parse(res.body)
  end

  # @param id [String]
  # @return [String]
  def status(id)
    res = RestClient.get("#{@uri_prefix}/#{id}/status")
    res = JSON.parse(res)
    unless res['id'] == id
      warn "Response ID '#{res['id']}' is different from query ID #{id}"
      exit 1
    end
    res['status']
  rescue RestClient::NotFound
    'Not found'
  end

  # @param id [String]
  # @return [String]
  def abort(id)
    res = RestClient.post("#{@uri_prefix}/#{id}/abort", {})
    res = JSON.parse(res)
    unless res['id'] == id
      warn "Response ID '#{res['id']}' is different from query ID #{id}"
      exit 1
    end
    res['status']
  rescue RestClient::NotFound
    'Not Found'
  end

  # @param id [String]
  # @return [Hash]
  def outputs(id)
    res = RestClient.get("#{@uri_prefix}/#{id}/outputs")
    res = JSON.parse(res)
    res['outputs']
  end
end
