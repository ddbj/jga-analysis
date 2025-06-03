# frozen_string_literal: true

require 'csv'
require 'fileutils'
require 'json'
require 'pathname'
require_relative 'cromwell_server'
require_relative 'settings'

class WorkflowManager
  class Submission
    attr_reader :workflow_id, :entity_type, :entity_id, :id

    # @param workflow_id [String]
    # @param entity_type [String]
    # @param entity_id [String]
    # @param id [String]
    def initialize(workflow_id, entity_type, entity_id, submission_id)
      @workflow_id = workflow_id
      @entity_type = entity_type
      @entity_id = entity_id
      @id = submission_id
    end
  end

  class Result
    attr_reader :status, :output

    # @param status [String]
    # @param output [Hash, nil]
    def initialize(status, output = nil)
      @status = status
      @output = output
    end

    # @return [Boolean]
    def should_resubmit?
      case @status
      when 'Aborted', 'Failed', 'Not found'
        true
      when 'Succeeded', 'Submitted', 'Running', 'Aborting'
        false
      else
        warn "Unknown status: #{status}"
        exit 1
      end
    end

    # @return [Boolean]
    def final?
      case @status
      when 'Succeeded'
        output ? true : false
      when 'Failed', 'Aborted', 'Not found'
        true
      else
        false
      end
    end
  end

  # @param cromwell [CromwellServer]
  # @param workflow_conf_dir [String]
  # @param submission_dir [String]
  def initialize(cromwell, workflow_conf_dir, submission_dir)
    @cromwell = cromwell
    @workflow_conf_dir = workflow_conf_dir
    @submission_dir = Pathname.new(submission_dir)
    @submission_path = @submission_dir / 'submission.tsv'
    unless @submission_path.exist?
      warn "Initializing #{@submission_path}"
      FileUtils.mkpath(@submission_dir)
      FileUtils.touch(@submission_path)
    end
    @submission_input_dir = @submission_dir / 'input'
    @result_path = @submission_dir / 'result.tsv'
    unless @result_path.exist?
      warn "Initializing #{@result_path}"
      FileUtils.mkpath(@submission_dir)
      FileUtils.touch(@result_path)
    end
    read
  end

  # @param workflow_id [String]
  # @param wdl_path [String]
  # @param deps_zip_path [String]
  # @param entities [Array<DataStore::Table::Entity>]
  # @param workspace_data [DataStore::KeyValue]
  # @param input_conf_path [String]
  # @param output_conf_path [String]
  # @param read_from_cache [Boolean]
  # @param force_resubmit [Boolean]
  # @return [Array<String>] submission ID and status
  def submit_multi(workflow_id:,
                   wdl_path:,
                   deps_zip_path:,
                   entities:,
                   workspace_data:,
                   input_conf_path:,
                   output_conf_path:,
                   read_from_cache:,
                   force_resubmit:)
    update_result
    last_result = collect_last_submission[workflow_id]&.transform_values do |submission|
      @result[submission.id]
    end
    CSV.open(@submission_path, 'a', col_sep: "\t", quote_char: "\x00") do |csv|
      entities.each do |entity|
        if last_result&.key?(entity.id) && !last_result[entity.id].should_resubmit? && !force_resubmit
          warn "Skips the following entity: #{workflow_id}, #{entity.type} #{entity.id} (#{last_result[entity.id].status})"
          next
        end
        submission_id, status = submit_kernel(workflow_id:,
                                              wdl_path:,
                                              deps_zip_path:,
                                              entity:,
                                              workspace_data:,
                                              input_conf_path:,
                                              output_conf_path:,
                                              read_from_cache:,
                                              force_resubmit:)
        next unless submission_id

        csv << [workflow_id, entity.type, entity.id, submission_id]
        @submissions << Submission.new(workflow_id, entity.type, entity.id, submission_id)
        @result[submission_id] = Result.new(status)
      end
    end
    write_result
  end

  # @param workflow_id [String]
  # @param wdl_path [String]
  # @param deps_zip_path [String]
  # @param entity [DataStore::Table::Entity]
  # @param workspace_data [DataStore::KeyValue]
  # @param input_conf_path [String]
  # @param output_conf_path [String]
  # @param read_from_cache [Boolean]
  # @param force_resubmit [Boolean]
  # @return [Array<String>] submission ID and status
  def submit(workflow_id:,
             wdl_path:,
             deps_zip_path:,
             entity:,
             workspace_data:,
             input_conf_path:,
             output_conf_path:,
             read_from_cache:,
             force_resubmit:)
    submit_multi(workflow_id:,
                 wdl_path:,
                 deps_zip_path:,
                 entities: [entity],
                 workspace_data:,
                 input_conf_path:,
                 output_conf_path:,
                 read_from_cache:,
                 force_resubmit:)
  end

  def print_status
    update_result
    write_result
    collect_last_submission.each do |workflow_id, h|
      h.each do |entity_id, submission|
        puts [
          workflow_id,
          submission.entity_type,
          entity_id,
          submission.id,
          @result[submission.id].status
        ].join("\t")
      end
    end
  end

  # @return [Array<Array>] array of [submission, result]
  def collect_result
    update_result
    write_result
    @submissions.map do |submission|
      [submission, @result[submission.id]]
    end
  end

  private

  # @return [Hash{ String => Hash { String => Submission }}] workflow ID -> entity ID -> submission
  def collect_last_submission
    @submissions.group_by(&:workflow_id).transform_values do |a|
      a.each_with_object({}) do |e, h|
        h[e.entity_id] = e
      end
    end
  end

  # @param workflow_id [String]
  # @param wdl_path [String]
  # @param deps_zip_path [String]
  # @param entity [DataStore::Table::Entity]
  # @param workspace_data [DataStore::KeyValue]
  # @param input_conf_path [String]
  # @param output_conf_path [String]
  # @param read_from_cache [Boolean]
  # @param force_resubmit [Boolean]
  # @return [Array<String>, nil] submission ID and status
  def submit_kernel(workflow_id:,
                    wdl_path:,
                    deps_zip_path:,
                    entity:,
                    workspace_data:,
                    input_conf_path:,
                    output_conf_path:,
                    read_from_cache:,
                    force_resubmit:)
    input_json_path = write_input_json(workflow_id, entity, workspace_data)
    option_json_path = write_option_json(workflow_id, entity, read_from_cache:)
    res = @cromwell.submit(wdl_path, deps_zip_path, input_json_path, option_json_path)
    submission_id = res['id']
    status = res['status']
    unless status == 'Submitted'
      puts "Submittion failed: #{res}"
      return nil
    end
    puts "Submitted #{workflow_id} with #{entity.type} '#{entity.id}' (submission ID = #{submission_id}, status = #{status})"
    [submission_id, status]
  end

  # @param workflow_id [String]
  # @param this [DataStore::Table::Entity]
  # @param workspace [DataStore::Keyvalue]
  # @return [Hash{ String => Object }]
  def fill_input(workflow_id, this:, workspace:)
    template_path = @workflow_conf_dir / "input/#{workflow_id}.json"
    input = JSON.parse(File.read(template_path)).transform_values! do |v|
      next v unless v.is_a?(String)
      next v unless v =~ /^\$\{(.+)\}$/

      src = Regexp.last_match(1)
      unless src =~ /^(\w+)\.(\w+|\w+.\w+)$/
        warn "Invalid source: #{src}"
        exit 1
      end
      src_location = Regexp.last_match(1)
      src_key = Regexp.last_match(2)

      case src_location
      when 'workspace'
        workspace[src_key]
      when 'this'
        this[src_key]
      else
        warn "Invalid source location: #{src_location}"
        exit 1
      end
    end
    input.compact
  end

  # @param workflow_id [String]
  # @param entity [DataStore::Table::Entity]
  # @param workspace_data [DataStore::KeyValue]
  # @return [String]
  def write_input_json(workflow_id, entity, workspace_data)
    json_path = @submission_input_dir / workflow_id / entity.id / "#{workflow_id}.input.json"
    input = fill_input(workflow_id, this: entity, workspace: workspace_data)
    FileUtils.mkpath(json_path.dirname)
    File.write(json_path, input.to_json)
    json_path
  end

  # @param workflow_id [String]
  # @param entity [DataStore::Table::Entity]
  # @param read_from_cache [Boolean]
  def write_option_json(workflow_id, entity, read_from_cache: true)
    json_path = @submission_input_dir / workflow_id / entity.id / "#{workflow_id}.option.json"
    option = {
      "final_workflow_log_dir": CROMWELL_DIR.expand_path / 'final_wf_logs',
      "final_call_logs_dir": CROMWELL_DIR.expand_path / 'final_call_logs'
    }
    option['read_from_cache'] = false unless read_from_cache
    FileUtils.mkpath(json_path.dirname)
    File.write(json_path, option.to_json)
    json_path
  end

  def read
    @submissions = CSV.read(@submission_path, col_sep: "\t", quote_char: "\x00").map do |row|
      Submission.new(*row)
    end
    @result = CSV.read(@result_path, col_sep: "\t", quote_char: "\x00").map.to_h do |submission_id, status, output|
      [submission_id, Result.new(status, JSON.parse(output))]
    end
  end

  def update_result
    @result = @submissions.map.to_h do |submission|
      result = @result[submission.id]
      unless result&.final?
        status = @cromwell.status(submission.id)
        result = if status == 'Succeeded'
                   Result.new(status, @cromwell.outputs(submission.id))
                 else
                   Result.new(status)
                 end
      end
      [submission.id, result]
    end
  end

  def write_result
    CSV.open(@result_path, 'w', col_sep: "\t", quote_char: "\x00") do |csv|
      @result.each do |submission_id, result|
        csv << [submission_id, result.status, result.output.to_json]
      end
    end
  end
end
