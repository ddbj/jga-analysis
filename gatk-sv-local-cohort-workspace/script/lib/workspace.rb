# frozen_string_literal: true

require 'fileutils'
require 'pathname'
require_relative 'cromwell_server'
require_relative 'data_store'
require_relative 'settings'
require_relative 'workflow_manager'
require_relative 'workspace/updater'

class Workspace
  class Workflow
    attr_reader :name, :id, :gatk_sv_version, :entities

    # @param name [String]
    # @param id [String]
    # @param gatk_sv_version [String]
    # @param entities [Array<DataStore::Table::Entity>]
    def initialize(name, id, gatk_sv_version, entities)
      @name = name
      @id = id
      @gatk_sv_version = gatk_sv_version
      @entities = entities
    end
  end

  attr_reader :workflows

  # @param workspace_dir [String]
  # @param workflow_conf_dir [String]
  # @param cromwell [CrowwellServer]
  def initialize(workspace_dir, workflow_conf_dir, cromwell)
    @workspace_dir = Pathname.new(workspace_dir)
    @workflow_conf_dir = Pathname.new(workflow_conf_dir)
    @data_dir = @workspace_dir / 'data'
    @submission_dir = @workspace_dir / 'submission'
    @data_store = DataStore.read(@data_dir)
    @workflow_manager = WorkflowManager.new(cromwell, @workflow_conf_dir, @submission_dir)
    @workflows = define_workflows(@data_store)
  end

  # @param workflow_name [String]
  # @param read_from_cache [Boolean]
  # @param force_resubmit [Boolean]
  def submit_workflow(workflow_name, read_from_cache: true, force_resubmit: false)
    unless @workflows.key?(workflow_name)
      warn "Invalid workflow name: #{workflow_name}"
      exit 1
    end

    workflow = @workflows[workflow_name]
    repo_dir = Pathname.new("gatk-sv-#{workflow.gatk_sv_version}-local")
    wdl_path = repo_dir / "wdl/#{workflow.id}.wdl"
    deps_zip_path = repo_dir / 'wdl/deps.zip'
    create_deps_zip_file(repo_dir, deps_zip_path) unless deps_zip_path.exist?

    input_conf_path = @workflow_conf_dir / "#{workflow.id}.json"
    output_conf_path = @workflow_conf_dir / "#{workflow.id}Output.json"
    @workflow_manager.submit_multi(workflow_id: workflow.id,
                                   wdl_path:,
                                   deps_zip_path:,
                                   entities: workflow.entities,
                                   workspace_data: @data_store.workspace_data,
                                   input_conf_path:,
                                   output_conf_path:,
                                   read_from_cache:,
                                   force_resubmit:)
  end

  def update_data
    Updater.run(@workflow_manager, @workflow_conf_dir, @data_store)
    write_data_with_backup
  end

  def print_submission_status
    @workflow_manager.print_status
  end

  # @param ped_path [String]
  def register_pedigree_file(ped_path)
    @data_store.workspace_data['cohort_ped_file'] = File.absolute_path(ped_path)
    write_data_with_backup
  end

  private

  def write_data_with_backup
   @data_store.write(@data_dir, backup: true)
  end

  # @param data_store [DataStore]
  # @return [Hash{ String => Workflow }]
  def define_workflows(data_store)
    samples = data_store.sample.entities
    batch = data_store.sample_set['all_samples']
    cohort = data_store.sample_set_set['all_batches']
    [
      ['01', 'GatherSampleEvidence',    GATK_SV_VERSION, samples],
      ['02', 'EvidenceQC',              GATK_SV_VERSION, [batch]],
      ['03', 'TrainGCNV',               GATK_SV_VERSION, [batch]],
      ['04', 'GatherBatchEvidence',     GATK_SV_VERSION, [batch]],
      ['05', 'ClusterBatch',            GATK_SV_VERSION, [batch]],
      ['06', 'GenerateBatchMetrics',    GATK_SV_VERSION, [batch]],
      ['07', 'FilterBatchSites',        GATK_SV_VERSION, [batch]],
      ['08', 'FilterBatchSamples',      GATK_SV_VERSION, [batch]],
      ['09', 'MergeBatchSites',         GATK_SV_VERSION, [cohort]],
      ['10', 'GenotypeBatch',           GATK_SV_VERSION, [batch]],
      ['11', 'RegenotypeCNVs',          GATK_SV_VERSION, [cohort]],
      ['12', 'CombineBatches',          GATK_SV_VERSION, [cohort]],
      ['13', 'ResolveComplexVariants',  GATK_SV_VERSION, [cohort]],
      ['14', 'GenotypeComplexVariants', GATK_SV_VERSION, [cohort]],
      ['15', 'CleanVcf',                GATK_SV_VERSION, [cohort]],
      ['16', 'RefineComplexVariants',   GATK_SV_VERSION, [cohort]],
      ['17', 'JoinRawCalls',            GATK_SV_VERSION, [cohort]],
      ['18', 'SVConcordance',           GATK_SV_VERSION, [cohort]],
      ['19', 'FilterGenotypes',         GATK_SV_VERSION, [cohort]],
      ['20', 'AnnotateVcf',             GATK_SV_VERSION, [cohort]]
    ].map.to_h do |prefix, workflow_id, gatk_sv_version, entities|
      workflow_name = "#{prefix}-#{workflow_id}"
      [workflow_name, Workflow.new(workflow_name, workflow_id, gatk_sv_version, entities)]
    end
  end

  # @param repo_dir [String]
  # @param deps_zip_path [String]
  def create_deps_zip_file(repo_dir, deps_zip_path)
    system "zip -j #{deps_zip_path} #{repo_dir}/wdl/*.wdl > /dev/null 2>&1"
  end
end
