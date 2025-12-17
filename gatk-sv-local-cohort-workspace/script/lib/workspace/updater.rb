# frozen_string_literal: true

require 'json'
require 'pathname'
require_relative '../cromwell_server'
require_relative '../data_store'
require_relative '../settings'
require_relative '../workflow_manager'

class Workspace
  module Updater
    class << self
      # @param manager [WorkflowManager]
      # @param workflow_conf_dir [String]
      # @param data_store [DataStore]
      def run(manager, workflow_conf_dir, data_store)
        workflow_conf_dir = Pathname.new(workflow_conf_dir)
        destination_template = Dir.glob(workflow_conf_dir / 'output' / '*.json').map.to_h do |path|
          workflow_id = File.basename(path).gsub(/Outputs\.json$/, '')
          [workflow_id, parse_template_json(path)]
        end

        manager.collect_result.each do |submission, result|
          next unless result.status == 'Succeeded'

          table = data_store.send(submission.entity_type)
          entity = table[submission.entity_id]

          template = destination_template[submission.workflow_id]
          if template
            write_output_according_to_template(result.output, entity, data_store.workspace_data, template)
          else
            write_output_by_default(result.output, entity, submission.workflow_id)
          end
        end
      end

      private

      # @param path [String]
      # @return [Hash[{ String => Array<String> }] source key -> ['this' or 'workspace', destination key]
      def parse_template_json(path)
        JSON.parse(File.read(path)).transform_values do |v|
          unless v.is_a?(String) && v =~ /^\$\{(\w+)\.(\w+)\}$/
            warn "Invalid destination: #{v}"
            exit 1
          end
          dest_location = Regexp.last_match(1)
          unless %w[this workspace].include?(dest_location)
            warn "Invalid destination location: #{dest_location}"
            exit 1
          end
          dest_key = Regexp.last_match(2)
          [dest_location, dest_key]
        end
      end

      # @param output [Hash{ String => Object }]
      # @param entity [DataStore::Table::Entity]
      # @param workspace_data [DataStore::KeyValue]
      # @param template [Hash[{ String => Array<String> }]
      def write_output_according_to_template(output, entity, workspace_data, template)
        template.each do |src, dest|
          value = output[src]
          dest_location, dest_key = dest
          case dest_location
          when 'this'
            entity[dest_key] = value
          when 'workspace'
            workspace_data[dest_key] = value
          end
        end
      end

      # @param output [Hash{ String => Object }]
      # @param entity [DataStore::Table::Entity]
      # @param workflo_id [String]
      def write_output_by_default(output, entity, workflow_id)
        output.each do |src, value|
          unless src =~ /^#{workflow_id}\.(\w+)$/
            warn "Invalid output key name: #{src}"
            exit 1
          end
          dest_key = Regexp.last_match(1)
          entity[dest_key] = value
        end
      end
    end
  end
end
