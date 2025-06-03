# frozen_string_literal: true

require 'csv'
require 'json'

class NamedTable
  include Enumerable

  attr_reader :title, :table

  # @param title [String]
  # @param table [CSV::Table]
  def initialize(title, table)
    @title = title
    @table = table
  end

  def each(&block)
    @table.each(&block)
  end

  # @param [String]
  def write(path)
    headers = @table.headers
    top_left = headers.shift
    top_left = "#{@title}:#{top_left}"
    headers.unshift(top_left)
    CSV.open(path, 'w', col_sep: "\t", quote_char: "\x00") do |csv|
      csv << headers
      @table.each do |row|
        encoded_row = row.map do |_, v|
          case v
          when Array, Hash
            v.to_json
          else
            v
          end
        end
        csv << encoded_row
      end
    end
  end

  class << self
    # @param path [String]
    def read(path)
      unless File.exist?(path)
        warn "File not exist: #{path}"
        exit 1
      end
      lines = File.readlines(path, chomp: true)
      top_line = lines.shift
      top_elements = top_line.split("\t")
      topleft = top_elements.shift
      topleft =~ /^(\w+):(\w+)$/
      title = Regexp.last_match(1)
      leftmost_column = Regexp.last_match(2)
      unless title
        warn "Failed to detect the table title from the topleft element: #{topleft}"
        exit 1
      end
      top_elements.unshift(leftmost_column)
      top_line = top_elements.join("\t")
      lines.unshift(top_line)
      table = CSV.parse(lines.join("\n"), col_sep: "\t", quote_char: "\x00", headers: true)
      decoded_rows = table.map do |row|
        headers = row.headers
        values = []
        row.each do |_, v|
          values << case v
                    when /^\{.*\}$/, /^\[.*\]$/
                      JSON.parse(v)
                    else
                      v
                    end
        end
        CSV::Row.new(headers, values)
      end
      decoded_table = CSV::Table.new(decoded_rows)
      NamedTable.new(title, decoded_table)
    end
  end
end
