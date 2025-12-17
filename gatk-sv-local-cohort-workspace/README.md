# gatk-sv-local-cohort-workspace

This repository `gatk-sv-local-cohort-workspace` provides utility tools for running the modified version of [GATK-SV](https://github.com/broadinstitute/gatk-sv) cohort-mode pipeline in a local HPC environment.

## Initial Setup

### Cloning the Repository

First, clone this repository.

```
$ git clone <THIS REPOSITORY>
```

### Installing Ruby Gems using Bundler

Because the utility tools are written in Ruby, you need to install the Ruby gems used in the tools.

Install Bundler if you have not already installed it.

```
$ gem install bundler
```

Enter `gatk-sv-local-cohort-workspace` directory and install the Ruby gems.


```
$ bundle install
```

### Downloading the Resources

Download the resource files (such as a reference) from Google Cloud Storage.

The download destination can be any directory. For example, if you want to download the resources to `resources` directory, run the following.

```
$ bundle exec ruby script/prepare_resources.rb resources
```

(During the downloading process, you will encounter several error messages from gcloud CLI. This is an expected behaviour and basically you do not need to care about them.)

After running the script, `workspace/data/workspace.tsv` is generated in addition to the resouce files. It is a table describing data used in the workflows.

Additionally, JSON files that define the inputs/outputs of WDL scripts are created under `workflow_configurations` directory.

These TSV and JSON file formats are compatible with the file format used in Terra platform.

#### Dependency

* Ruby (tested with 3.3.4)
* Python (tested with 3.10.5)
* gcloud CLI

### Caching Apptainer Images

We suppose you to use Apptainer as a container platform. It is highly recommended that you build and store the Apptainer images before starting the GATK-SV workflows. (Although Apptainer automatically tries to build the images during a workflow run, it may fail if the memory allocated to the backend job is not sufficient.)

Build Apptainer images from Docker image paths described in `workspace/data/dockers.json`.

```
$ script/build_apptainer_images.sh
```

Here, MELT image is excluded from the build target (because it is not required from the current version of GATK-SV and not downloadable due to the permission).

## Running MySQL Server

We use MySQL as a RDBMS for storing Cromwell execution history. Scripts that control MySQL server is placed under `mysql` directory.

```
$ cd mysql
```

Initialize MySQL database using the following command.

```
$ ./mysql_init.sh
```

By running this, `.my.cnf` is created under the home directory. (NOTE: The file is overwritten if it already exists.)

By default, the data directory is `/data1/${USER}` and the port number is 33061. You can modify these parameters and the database root password by editing `mysql_params.sh` before running the initialization script. We recommend you to use a low-latency filesystem for the database location.

After running the initialization script, you can start MySQL Apptainer container. [Apptainer instance](https://apptainer.org/docs/user/main/cli/apptainer_instance.html) is used to make container run in the background. After running the container, we can start MySQL server inside the container. The following script launches both the container and MySQL server.

```
$ ./mysql_start.sh
```

This script keeps running in the foreground. In a real situation, it is recommended to run it under the control of job scheduler (for example, by using `sbatch` in Slurm).

To finish the MySQL, stop the above script first. The Apptainer instance is still running in the background and you should terminate this by the following.


```
$ ./mysql_stop.sh
```

### Dependency

* Java (tested with openjdk 22.0.1-internal 2024-04-16)

## Running Cromwell Server

Programs and settings related to Cromwell server are placed under `cromwell` directory.

```
$ cd cromwell
```

The default configuration file for Cromwell is `nig-pg.conf`, tuned for NIG (National Institute of Genetics, Japan) supercomputer environment. You should modify it according to your environment. For example, if you need to run jobs inside a specific Slurm partition or nodes, you have to add `-p` or `--nodelist` options to `sbatch` command. If you need to change the port number of Cromwell server (8000 by default), you can [manually specify the port number](https://cromwell.readthedocs.io/en/latest/Configuring/#server). (In that case, you have to modify the port number in `cromwell/network.json` to the same number.)

Start a Cromwell server by the following script. You should run the Cromwell server in the same node where the MySQL server is running, as they communicate with each other.

```
$ ./run_cromwell_server.sh
```

In a real situation, it is recommended to run this under the control of job scheduler (for example, by using `sbatch` in Slurm, adding option like `-c 16 --mem 40G`).

### Dependency

* Java (tested with openjdk 22.0.1-internal 2024-04-16)

## Describing Data

Before running the workflows, you should describe the target data in tables. The format is same as that used in Terra platform.

The followings are the table files needed to be described. You should place them under `workspace/data` directory. They are hierarchically organized in three levels: sample, sample_set, and sample_set_set.

* `sample.tsv`
* `sample_set_entity.tsv`, `sample_set_membership.tsv`
* `sample_set_set_entity.tsv`, `sample_set_set_membership.tsv`

During the workflow run, the tables are updated and the results are added as new columns. In the following, we explain the columns required for the initial setup.

### Sample

We need to describe two columns, sample ID and BAM/CRAM path, in `sample.tsv` like the following. The first line is the header (do not modify it).

```sample.tsv
entity:sample_id  bam_or_cram_file
HG00096           HG00096.cram
HG00129           HG00129.cram
.
.
.
```

### Sample set

The sample set IDs are described in `sample_set_entity.tsv`.

```sample_set_entity.tsv
entity:sample_set_id
all_but_hg00096
all_samples
.
.
.
```

The correspondences between sample set and its member samples are described in `sample_set_membership.tsv`.

```sample_set_membership.tsv
membership:sample_set_id  sample
all_but_hg00096           HG00129
all_but_hg00096           HG00140
.
.
.
all_samples               HG00096
all_samples               NA18956
.
.
.
```

### Sample set set

In a similar fashion, sample set set IDs are described in `sample_set_set_entity.tsv`.

```sample_set_set_entity.tsv
entity:sample_set_set_id
all_batches
.
.
.
```

The correspondences between sample set set and its member sample sets are described in `sample_set_set_membership.tsv`.

```sample_set_set_membership.tsv
membership:sample_set_set_id  sample_set
all_batches                   all_samples
.
.
.
```

## Running the Workflows

### Workflow Submission

Script `submit_workflow.rb` allows a user to submit GATK-SV cohort mode workflows. Help message is shown below.

```
$ bundle exec ruby script/submit_workflow.rb -h
Usage: script/submit_workflow.rb WORKFLOW_NAME

Workflow name:
  01-GatherSampleEvidence
  02-EvidenceQC
  03-TrainGCNV
  04-GatherBatchEvidence
  05-ClusterBatch
  06-GenerateBatchMetrics
  07-FilterBatchSites
  08-FilterBatchSamples
  09-MergeBatchSites
  10-GenotypeBatch
  11-RegenotypeCNVs
  12-CombineBatches
  13-ResolveComplexVariants
  14-GenotypeComplexVariants
  15-CleanVcf
  16-RefineComplexVariants
  17-JoinRawCalls
  18-SVConcordance
  19-FilterGenotypes
  20-AnnotateVcf

    -C, --disable-cache
    -f, --force-resubmit
```

To run a workflow, you should specify the workflow name as an argument. For example, if you want to run `01-GatherSampleEvidence`, run the following.

```
$ bundle exec ruby script/submit_workflow.rb 01-GatherSampleEvidence
```

Workflows need to be executed in order, from 01 to 20. (NOTE: you need a manual QC after `02-EvidenceQC` as explained later.)

### Workflow Monitoring

The status of the workflows can be monitored by the following.

```
$ bundle exec ruby script/workflow_status.rb
```

The example is shown below.

```
$ bundle exec ruby script/workflow_status.rb
GatherSampleEvidence  sample          NA20764      5783ac5a-c405-4374-bdc8-84559a10a01d  Succeeded
GatherSampleEvidence  sample          NA20802      4c197412-9430-4ef0-babd-fcad28e189a3  Succeeded
GatherSampleEvidence  sample          NA20845      89aba914-7c4c-49f1-bee7-377f80beb98e  Succeeded
GatherSampleEvidence  sample          NA20869      57d3fb03-0125-42a1-b9a9-c2d0a12700ba  Succeeded
GatherSampleEvidence  sample          NA20895      570536d6-ae4c-433e-82d2-710ba9579146  Succeeded
GatherSampleEvidence  sample          NA21102      eb3d4f6c-3438-4457-840b-0621f1bbde26  Succeeded
GatherSampleEvidence  sample          NA21122      cd053045-b785-43fa-9136-e4451eff04a5  Succeeded
GatherSampleEvidence  sample          NA21133      178b2783-46b1-4d89-b0c2-8e0223d317b6  Succeeded
EvidenceQC            sample_set      all_samples  bd42d7c4-d9e0-40ee-aaf7-97771c3b85f5  Succeeded
TrainGCNV             sample_set      all_samples  9339e23b-b803-4a68-af11-3330ddc55703  Succeeded
GatherBatchEvidence   sample_set      all_samples  5eca9703-ad16-428c-919d-202ad8e0fbd0  Succeeded
ClusterBatch          sample_set      all_samples  fddc7402-4cac-4fc6-8d84-52adb98f1897  Succeeded
GenerateBatchMetrics  sample_set      all_samples  e67dc4fc-193c-4025-9735-14d6e3fc526c  Succeeded
FilterBatchSites      sample_set      all_samples  c81caf73-8a5c-4776-8f2f-be736853b7f6  Succeeded
FilterBatchSamples    sample_set      all_samples  0c6a5efa-bd60-44c1-91ba-0d101fd1784d  Succeeded
MergeBatchSites       sample_set_set  all_batches  f5198c75-fa37-4333-9bf0-e4324239a800  Succeeded
GenotypeBatch         sample_set      all_samples  66baade3-43ef-4a1c-9bed-109e4fabff29  Succeeded
RegenotypeCNVs        sample_set_set  all_batches  0802c0a4-54b1-4aac-b1b4-ad175bc90c81  Succeeded
```

The columns are workflow ID, the unit of calculation, the calculation target ID, workflow UUID assigned by Cromwell, and workflow status from left to right.

Sometimes, the same workflow for the same target is submitted more than once (for example, to retry failed calculations). In such a case, the result from the last submission is employed in the subsequent workflows and only the last submission is shown in the output of this script.

### Updating Results

After a workflow finishes, the result is written to the TSV files under `workspace/data` by running the following script.

```
$ bundle exec ruby script/update_data.rb
```

Because workflows from 01 to 20 have dependencies, we need to reflect the previous results to the data files before running the workflows of the next step. In fact, `submit_workflow.rb` automatically updates the previous results to the data files before the submission of a new workflow. Therefore, basically you do not need to manually run `update_data.rb` except for the final step. After running the final `20-AnnotateVcf`, there is no subsequent workflow and you need to manually update the data files by running `script/update_data.rb`.

### Registering a Pedigree File

After running `02-EvidenceQC`, we manually perform [QC and batching](https://broadinstitute.github.io/gatk-sv/docs/modules/eqc#preliminary-sample-qc).

At this step, you are required to prepare a pedigree file (PED format). This can be registered to the data file by the following.

```
$ bundle exec ruby script/register_pedigree_file.rb <PED_FILE>
```

### Dependency

* Ruby (tested with 3.3.4)
