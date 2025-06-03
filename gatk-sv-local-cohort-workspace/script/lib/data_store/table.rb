# frozen_string_literal: true

require 'active_support/inflector'
require 'csv'
require 'fileutils'
require 'json'
require 'set'
require_relative 'named_table'

class DataStore
  class Table
    include Enumerable

    class Entity
      attr_reader :type, :child_type, :child_entities

      # @param type [String]
      # @param attritube [Hash{ String => Object }]
      # @param child_type [String, nil]
      # @param child_entities [Array<Entity>, nil]
      def initialize(type, attribute, child_type = nil, child_entities = nil)
        @type = type
        @attribute = attribute
        @child_type = child_type
        @child_entities = child_entities
      end

      # @return [String]
      def id
        @attribute["#{@type}_id"]
      end

      # @param key [String]
      # @return [Object]
      def [](key)
        return @attribute[key] unless @child_type && key =~ /^#{traversal_keyname}\.(\w+)$/

        child_key = Regexp.last_match(1)
        child_values = @child_entities.map { |e| e[child_key] }
        if child_values.all? { |e| !e.nil? }
          child_values
        elsif child_values.all?(&:nil?)
          nil
        else
          warn "Values for '#{key}' of #{type} '#{id}' are partially null and partially non-null"
          exit 1
        end
      end

      # @param key [String]
      # @param value [Object]
      def []=(key, value)
        unless key =~ /^\w+$/
          warn "Invalid key for #{@type} entity (id = #{id}): #{key}"
          exit 1
        end
        @attribute[key] = value
      end

      # @return [Array<String>]
      def keys
        @attribute.keys
      end

      # @return [Hash{ String => Object }]
      def to_hash
        @attribute
      end

      private

      # @return [String]
      def traversal_keyname
        unless @child_type
          warn 'The entity does not have children'
          exit 1
        end
        @child_type.pluralize
      end
    end

    attr_reader :type, :entities

    def initialize(type, entities, child_type = nil)
      @type = type
      @entities = entities
      @entity_by_id = entities.map.to_h do |e|
        [e.id, e]
      end
      @child_type = child_type
    end

    def each(&block)
      @entities.each(&block)
    end

    # @param id [String]
    # @return [Entity]
    def [](id)
      @entity_by_id[id]
    end

    # @param entity_path [String]
    # @param membership_path [String, nil]
    def write(entity_path, membership_path = nil)
      entity_keys = all_keys
      entity_rows = @entities.map do |e|
        CSV::Row.new(entity_keys, entity_keys.map { |k| e[k] })
      end
      entity_table = CSV::Table.new(entity_rows)
      NamedTable.new('entity', entity_table).write(entity_path)
      return unless membership_path

      membership_rows = @entities.flat_map do |parent|
        parent.child_entities.map do |child|
          CSV::Row.new(["#{parent.type}_id", child.type], [parent.id, child.id])
        end
      end
      membership_table = CSV::Table.new(membership_rows)
      NamedTable.new('membership', membership_table).write(membership_path)
    end

    private

    # @return [Array<String>]
    def all_keys
      keys = Set.new
      @entities.each { |e| keys.merge(e.keys) }
      keys.to_a
    end

    class << self
      # @param type [String]
      # @param entity_path [String]
      # @param membership_path [String, nil]
      # @param child_table [Table, nil]
      # @return [Table]
      def read(type, entity_path, membership_path = nil, child_table = nil)
        entity_table = NamedTable.read(entity_path)
        membership_table = NamedTable.read(membership_path) if membership_path
        entities = entity_table.map do |row|
          attribute = row.to_hash
          id = attribute["#{type}_id"]
          if membership_table && child_table
            child_entities = collect_children(type, id, membership_table, child_table)
            Entity.new(type, attribute, child_table.type, child_entities)
          else
            Entity.new(type, attribute)
          end
        end
        Table.new(type, entities, child_table&.type)
      end

      private

      # @param parent_type [String]
      # @param parent_id [String]
      # @param membership_table [Table]
      # @param child_table [Table]
      # @return [Array<Entity>]
      def collect_children(parent_type, parent_id, membership_table, child_table)
        child_type = child_table.type
        child_ids = membership_table.filter_map do |row|
          next unless row["#{parent_type}_id"] == parent_id

          row[child_type]
        end
        child_ids.map do |id|
          unless child_table[id]
            warn "Cannot not find a #{child_type} in #{parent_type} '#{parent_id}' membership: #{id}"
            exit 1
          end
          child_table[id]
        end
      end
    end
  end
end
