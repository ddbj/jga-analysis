# frozen_string_literal: true

require 'fileutils'
require 'pathname'
require_relative 'data_store/table'
require_relative 'data_store/keyvalue'

class DataStore
  attr_reader :sample, :sample_set, :sample_set_set, :workspace_data

  # @param sample [Table]
  # @param sample_set [Table]
  # @param sample_set_set [Table]
  # @param workspace_data [KeyValue]
  def initialize(sample, sample_set, sample_set_set, workspace_data)
    @sample = sample
    @sample_set = sample_set
    @sample_set_set = sample_set_set
    @workspace_data = workspace_data
  end

  # @param dir [String]
  # @param backup [Boolean]
  def write(dir, backup: false)
    path = DataStore.data_paths_from_directory(dir)
    if backup
      path.each_value do |path|
        next unless path.exist?

        FileUtils.cp(path, "#{path}.bak")
      end
    end
    @sample.write(path[:sample_entity])
    @sample_set.write(path[:sample_set_entity], path[:sample_set_membership])
    @sample_set_set.write(path[:sample_set_set_entity], path[:sample_set_set_membership])
    @workspace_data.write(path[:workspace_data])
  end

  class << self
    # @param dir [String]
    # @return [Hash{ Symbol => Pathname }]
    def data_paths_from_directory(dir)
      dir = Pathname.new(dir)
      {
        sample_entity: dir / 'sample.tsv',
        sample_set_entity: dir / 'sample_set_entity.tsv',
        sample_set_membership: dir / 'sample_set_membership.tsv',
        sample_set_set_entity: dir / 'sample_set_set_entity.tsv',
        sample_set_set_membership: dir / 'sample_set_set_membership.tsv',
        workspace_data: dir / 'workspace.tsv'
      }
    end

    # @param dir [String]
    # @return [DataStore]
    def read(dir)
      path = data_paths_from_directory(dir)
      sample = Table.read('sample', path[:sample_entity])
      sample_set = Table.read('sample_set',
                              path[:sample_set_entity],
                              path[:sample_set_membership],
                              sample)
      sample_set_set = Table.read('sample_set_set',
                                  path[:sample_set_set_entity],
                                  path[:sample_set_set_membership],
                                  sample_set)
      workspace_data = KeyValue.read(path[:workspace_data])
      DataStore.new(sample, sample_set, sample_set_set, workspace_data)
    end
  end
end
