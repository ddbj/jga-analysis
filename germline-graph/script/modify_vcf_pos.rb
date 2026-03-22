# frozen_string_literal: true

RefBase = Struct.new(:chr, :pos, :base)

dup_path = ARGV.shift
dup = Hash.new
File.foreach(dup_path, chomp: true) do |line|
  chr, pos, ref, id = line.split("\t")
  pos = pos.to_i
  dup[id] = RefBase.new(chr, pos, ref[0])
end

ARGF.each(chomp: true) do |line|
  if line =~ /^#/
    puts line
    next
  end

  fields = line.split("\t")
  chr = fields[0]
  pos = fields[1].to_i
  id = fields[2]
  ref = fields[3]
  alt = fields[4]

  unless dup.key?(id)
    puts line
    next
  end

  case pos
  when dup[id].pos
    puts line
  when dup[id].pos + 1
    if alt == '.'
      warn "Cannot modify a VCF with ALT = '.'"
      exit 1
    end

    pos = (pos - 1).to_s
    b = dup[id].base
    ref = "#{b}#{ref}"
    alt = alt.split(',').map { |e| "#{b}#{e}" }.join(',')
    puts [chr, pos, id, ref, alt, fields[5..]].flatten.join("\t")
  else
    warn "Duplicate IDs should appear in two consecutive lines: id = #{id}, chr = #{chr}, pos = #{pos}"
    exit 1
  end
end
