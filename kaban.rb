require 'bundler/setup'
Bundler.require(:default)

require 'thor'
require 'configatron'
require 'yaml'
require 'hashie'
require 'elasticsearch'
require 'jira'
require 'json'
require 'retriable'
require 'mongo'
require 'pp'

require_relative 'kaban/base/base_transformer'
require_relative 'kaban/base/base_extractor'

require_relative 'kaban/core/indexer'
require_relative 'kaban/core/repository'
require_relative 'kaban/core/workspace'

require_relative 'kaban/services/pipeline'
require_relative 'kaban/services/class_loader'

$stdout.sync = true

configatron.configure_from_hash(
  YAML.load_file('./kaban/config.yml').merge(
    env: YAML.load_file('./repository/environment.yml')
  )
)

class Kaban < Thor
  desc 'config', 'print configuration'
  def config
    puts configatron.inspect
  end

  desc 'sync <collection>', 'extract + transform + load'
  def sync(collection_name)
    extract(collection_name)
    transform(collection_name)
    load(collection_name)
  end

  desc 'extract <collection>', 'extract'
  def extract(collection_name)
    Pipeline.extract(Repository::Collections.find(collection_name))
  end

  desc 'transform <collection>', 'transform'
  def transform(collection_name)
    Pipeline.transform(Repository::Collections.find(collection_name))
  end

  desc 'load <collection>', 'load'
  def load(collection_name)
    Pipeline.load(Repository::Collections.find(collection_name))
  end
end

Kaban.start(ARGV)
