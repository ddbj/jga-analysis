# frozen_string_literal: true

require 'csv'
require_relative 'named_table'

class DataStore
  class KeyValue
    # @param hash [Hash{ String => Object }]
    def initialize(hash)
      @hash = hash
    end

    # @param key [String]
    # @return [Object]
    def [](key)
      @hash[key]
    end

    # @param key [String]
    # @param value [Object]
    def []=(key, value)
      @hash[key] = value
    end

  # @param path [String]
    def write(path)
      keys = @hash.keys
      row = CSV::Row.new(keys, @hash.values_at(*keys))
      table = CSV::Table.new([row])
      NamedTable.new('workspace', table).write(path)
    end

    class << self
      def read(path)
        table = NamedTable.read(path).table
        KeyValue.new(table.first.to_hash)
      end
    end
  end
end
