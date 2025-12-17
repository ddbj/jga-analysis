# frozen_string_literal: true

require 'fileutils'
require 'pathname'

# @param uris [String]
# @param data_dir [Pathname]
# @param inspect_secondary_file [Boolean]
# @param no_clobber [Boolean]
# @param dry_run [Boolean]
# @return [Hash { String => Pathname }] URI -> local path
def download_gcp_files(uris,
                       data_dir,
                       inspect_secondary_file: false,
                       no_clobber: true,
                       dry_run: false)
  extended_uris = []
  uris.each do |uri|
    extended_uris << uri
    next unless inspect_secondary_file

    case uri
    when /\.bed\.gz$/, /\.vcf\.gz$/, /\.txt\.gz$/
      extended_uris << "#{uri}.tbi"
    when /\.bed$/, /\.vcf$/
      extended_uris << "#{uri}.idx"
    when /\.fa$/, /\.fa\.gz$/, /\.fasta$/, /\.fasta\.gz$/
      extended_uris << "#{uri}.fai"
    when /\.bam$/
      extended_uris << "#{uri}.bai"
    when /\.cram$/
      extended_uris << "#{uri}.crai"
    end
  end
  extended_uris.uniq!

  extended_uris.map.to_h do |uri|
    uri =~ %r{^gs://(.+)$}
    dst_path = data_dir / Regexp.last_match(1)
    FileUtils.mkpath dst_path.dirname
    warn "Downloading #{uri}"
    unless dry_run || no_clobber && dst_path.exist?
      cmd = [
        'gcloud',
        'storage',
        'cp',
        '-r',
        no_clobber ? '-n' : nil,
        uri,
        dst_path.dirname
      ].compact.join(' ')
      system cmd
    end
    [uri, dst_path]
  end
end
