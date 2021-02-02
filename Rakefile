# frozen_string_literal: true

require 'pathname'

GITHUB_ACCOUNT = 'tafujino'
REPOSITORY = 'jga-analysis'

# @param workflow [String]
# @param image    [String]
def define_image_tasks(workflow, image)
  namespace workflow do
    namespace image do
      tag = "ghcr.io/#{GITHUB_ACCOUNT}/#{REPOSITORY}/#{image}:latest"

      desc 'build a Docker image'
      task :build do
        sh "docker build -t #{tag} #{workflow}/docker/#{image}"
      end

      desc 'push a Docker image'
      task :push do
        sh "docker push #{tag}"
      end
    end
  end
end

desc 'login to GitHub Container Registry'
task :login do
  sh "echo $CR_PAT | docker login ghcr.io -u #{GITHUB_ACCOUNT} --password-stdin"
end

FileList['*/docker/*'].each do |path|
  path = Pathname.new(path)
  workflow = path.dirname.dirname.to_s
  image = path.basename.to_s
  define_image_tasks(workflow, image)
end
