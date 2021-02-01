# frozen_string_literal: true

GITHUB_ACCOUNT = 'tafujino'
REPOSITORY = 'human-seq-secondary'
IMAGES = %w[fastq2bam]

# @param iamge [String]
def define_image_tasks(image)
  namespace image do
    desc 'build a Docker image'
    task :build do
      tag = "ghcr.io/#{GITHUB_ACCOUNT}/#{REPOSITORY}/#{image}:latest"
      sh "docker build -t #{tag} docker/#{image}"
    end
  end
end

IMAGES.each { |image| define_image_tasks(image) }
