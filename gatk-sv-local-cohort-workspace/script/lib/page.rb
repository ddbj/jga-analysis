# frozen_string_literal: true

class Page
  # @param before [Array<String>]
  # @param after [Array<String>]
  def initialize(before, after)
    @before = before
    @after = after
  end

  # @param path [String]
  def write(path)
    File.write(path, (@before + @after).join("\n"))
  end

  # @param regexp [Regexp]
  # @return [String] the matched line
  def skip(regexp)
    while (line = @after.shift)
      @before << line
      next unless line =~ regexp

      return line
    end

    warn "Failed to find the line matching '#{regexp}'"
    exit 1
  end

  # @param str [String]
  # @param offset [Integer, nil]
  def insert(str, offset: nil)
    if offset
      indent = get_indent(@before.last) + ' ' * offset
      str = "#{indent}#{str}"
    end
    @before << str
  end

  def remove_previous_line
    @before.pop
  end

  # @param regexp [Regexp]
  def skip_and_replace_matched(regexp)
    line = skip(regexp)
    remove_previous_line
    new_line = yield line
    insert(new_line)
  end

  private

  # @param line [String]
  def get_indent(line)
    line[/^(\s*)/, 1]
  end

  class << self
    # @param path [String]
    def read(path)
      lines = File.readlines(path, chomp: true)
      Page.new([], lines)
    end

    # @param path [String]
    # @yieldparam [Page]
    def modify(path)
      page = read(path)
      yield page
      page.write(path)
    end
  end
end
