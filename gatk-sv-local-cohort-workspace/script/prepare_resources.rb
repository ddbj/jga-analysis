# frozen_string_literal: true

require 'csv'
require 'fileutils'
require 'optparse'
require 'pathname'
require_relative 'lib/gcp'
require_relative 'lib/page'
require_relative 'lib/settings'

# @param version [String]
# @param repo_dir [String]
def clone_repo_and_checkout(version, repo_dir)
  if File.exist?(repo_dir)
    warn "Already exists: #{repo_dir}"
  else
    ret = system "git clone https://github.com/broadinstitute/gatk-sv.git #{repo_dir}"
    unless ret
      warn 'Failed to clone gatk-sv repository'
      exit 1
    end
  end
  warn "Restoring version '#{version}'"
  Dir.chdir(repo_dir) do
    ret = system "git restore . --source #{version}"
    unless ret
      warn "Failed to restore version '#{version}'"
      exit 1
    end
  end
end

# @param repo_dir [Pathname]
# @param download_dir [Pathname]
# @param no_clobber [Boolean]
# @param dry_run [Boolean]
def download_resouces_hg38_and_rewrite_paths(repo_dir, download_dir, no_clobber: true, dry_run: false)
  json_path = repo_dir / 'inputs/values/resources_hg38.json'
  str = File.read(json_path)
  uris = []
  str.gsub!(%r{"(gs://([^"]+))"}) do
    uris << Regexp.last_match(1)
    rel_path = Regexp.last_match(2)
    "\"#{download_dir / rel_path}\""
  end
  download_gcp_files(uris, download_dir, inspect_secondary_file: true, no_clobber:, dry_run:)
  File.write(json_path, str)
end

# @param repo_dir [Pathname]
def build_inputs(repo_dir)
  warn 'Building Terra cohort mode workspace inputs'
  Dir.chdir(repo_dir) do
    values_dir = 'inputs/values'
    template_path = 'inputs/templates/terra_workspaces/cohort_mode'
    out_dir = 'inputs/build'
    system "scripts/inputs/build_inputs.py #{values_dir} #{template_path} #{out_dir}"
  end
end

# @param conf_dir [Pathname]
def rewrite_gather_sample_evidence_input(conf_dir)
  Page.modify(conf_dir / 'GatherSampleEvidence.json.tmpl') do |page|
    page.skip(/^\s*"GatherSampleEvidence.bam_or_cram_file"/)
    page.insert('"GatherSampleEvidence.run_localize_reads": false,', offset: 0)
  end
end

# @param conf_dir [Pathname]
def rewrite_genotype_batch_input(conf_dir)
  Page.modify(conf_dir / 'GenotypeBatch.json.tmpl') do |page|
    page.skip(/^\s*"GenotypeBatch.discfile"/)
    page.insert('"GenotypeBatch.discfile_index": "${this.merged_PE_index}",', offset: 0)
    page.skip(/^\s*"GenotypeBatch.coveragefile"/)
    page.insert('"GenotypeBatch.coveragefile_index": "${this.merged_bincov_index}",', offset: 0)
    page.skip(/^\s*"GenotypeBatch.splitfile"/)
    page.insert('"GenotypeBatch.splitfile_index": "${this.merged_SR_index}",', offset: 0)
  end
end

# @param conf_dir [Pathname]
def rewrite_sv_concordance_input(conf_dir)
  Page.modify(conf_dir / 'SVConcordance.json.tmpl') do |page|
    page.skip(/^\s*"SVConcordance.eval_vcf"/)
    page.insert('"SVConcordance.eval_vcf_index" : "${this.cpx_refined_vcf_index}",', offset: 0)
    page.skip(/^\s*"SVConcordance.truth_vcf"/)
    page.insert('"SVConcordance.truth_vcf_index" : "${this.joined_raw_calls_vcf_index}",', offset: 0)
  end
end

# @param repo_dir [Pathname]
def rewrite_workflow_configurations(repo_dir)
  conf_dir = repo_dir / 'inputs/templates/terra_workspaces/cohort_mode/workflow_configurations'
  rewrite_gather_sample_evidence_input(conf_dir)
  rewrite_genotype_batch_input(conf_dir)
  rewrite_sv_concordance_input(conf_dir)
end

# Since Docker image "marketplace.gcr.io/google/ubuntu1804" is not accesible without authentication,
# we use "ubuntu:18.04" instead
# @param repo_dir [Pathname]
def rewrite_docker_image(repo_dir)
  Page.modify(repo_dir / "inputs/values/dockers.json") do |page|
    page.skip_and_replace_matched(/^\s*"linux_docker":/) do |line|
      line.sub(/"linux_docker": "[^"]*"/, '"linux_docker": "ubuntu:18.04"')
    end
  end
end

# @param repo_dir [Pathname]
def copy_build_results(repo_dir)
  workspace_data_dir = WORKSPACE_DIR / 'data'
  FileUtils.mkpath(workspace_data_dir)
  FileUtils.cp(repo_dir / "inputs/build/workspace.tsv", workspace_data_dir)
  FileUtils.cp(repo_dir / "inputs/values/dockers.json", workspace_data_dir)
  FileUtils.mkpath(WORKFLOW_CONF_DIR / 'input')
  FileUtils.cp(Dir.glob(repo_dir / 'inputs/build/workflow_configurations/*.json'), WORKFLOW_CONF_DIR / 'input')
  FileUtils.mkpath(WORKFLOW_CONF_DIR / 'output')
  FileUtils.cp(Dir.glob(repo_dir / 'inputs/build/workflow_configurations/output_configurations/*.json'), WORKFLOW_CONF_DIR / 'output')
end

opt = OptionParser.new
no_clobber = false
skip_download = false
opt.on('-C', '--no-clobbber') { no_clobber = true }
opt.on('-D', '--skip-download') { skip_download = true }
opt.banner = "Usage: #{$PROGRAM_NAME} DOWNLOAD_DIR [options]"
opt.parse!(ARGV)

if ARGV.length < 1
  puts opt.banner
  exit 1
end

download_dir = Pathname.new(ARGV.shift).expand_path
version = GATK_SV_VERSION

repo_dir = Pathname.new("gatk-sv-cohort-inputs-build-#{version}")
clone_repo_and_checkout(version, repo_dir)
rewrite_workflow_configurations(repo_dir)
rewrite_docker_image(repo_dir)
download_resouces_hg38_and_rewrite_paths(repo_dir, download_dir, no_clobber:, dry_run: skip_download)
build_inputs(repo_dir)
copy_build_results(repo_dir)
