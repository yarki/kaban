require 'thor'
require 'configatron'
require 'yaml'
require 'hashie'
require 'elasticsearch'
require 'jira'
require 'json'
require 'retriable'

require_relative 'kaban/core/indexer'
require_relative 'kaban/core/repository'
require_relative 'kaban/core/workspace'
require_relative 'kaban/core/synchronizer'
require_relative 'kaban/core/fetcher'
require_relative 'kaban/core/transformer'

$stdout.sync = true

configatron.configure_from_hash(
  YAML.load_file('./kaban/config.yml').merge(
    env: YAML.load_file('./repository/environment.yml')
  )
)

# Main class
class Kaban < Thor
  desc 'config', 'print configuration'
  def config
    puts configatron.inspect
  end

  desc 'fetch <collection>', 'fetch raw documents'
  def fetch(collection_name = nil)
    Repository.collections(name: collection_name).each do
      |collection|
      docs = Synchronizer.fetch collection: collection
      Workspace.save_raw docs: docs, collection: collection
    end
  end

  desc 'map <collection>', 'apply mapping'
  def map(collection_name = nil)
    Repository.collections(name: collection_name).each do
      |collection|
      raw_docs = Workspace.load_raw collection: collection
      mapping = Repository.load_mapping name: collection.mapper.mapping
      mapped_docs = Transformer.map collection: collection,
        raw_docs: raw_docs, mapping: mapping
      Workspace.save_mapped collection: collection, docs: mapped_docs
    end
  end

  desc 'index <collection>', 'index mapped documents'
  def index(collection_name = nil)
    Repository.collections(name: collection_name).each do
      |collection|
      docs = Workspace.load_mapped collection: collection
      Indexer.index collection: collection, docs: docs
    end
  end

  desc 'init', 'init kaban repository'
  def init
  end

  desc 'sync <collection>', 'fetch + map + index'
  def sync(collection_name = nil)
    fetch collection_name
    map collection_name
    reset collection_name
    index collection_name
  end
end

Kaban.start(ARGV)
