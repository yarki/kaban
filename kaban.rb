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
	YAML.load_file('./kaban/config.yml').merge({'env' => YAML.load_file('./repository/environment.yml')})
)

class Kaban < Thor
	
	desc 'config', 'print configuration'
	def config
		puts configatron.inspect
	end

	desc 'reset', 'reset collections'
	def reset
		Repository.collections.each { |collection|
			schema = Repository.load_schema name: collection.indexer.schema
			Indexer.reset collection: collection, schema: schema
		}
	end

	desc 'fetch', 'fetch raw data'
	def fetch
		Repository.collections.each { |collection|
			docs = Synchronizer.fetch collection: collection
			Workspace.save_raw docs: docs, collection: collection
		}
	end

	desc 'map', 'apply mappings'
	def map
		Repository.collections.each { |collection|
			raw_docs = Workspace.load_raw collection: collection
			mapping = Repository.load_mapping name: collection.mapper.mapping
			mapped_docs = Transformer.map collection: collection, raw_docs: raw_docs, mapping: mapping
			Workspace.save_mapped collection: collection, docs: mapped_docs  
		}
	end

	desc 'index', 'index all'
	def index
		Repository.collections.each { |collection|
			docs = Workspace.load_mapped collection: collection
			schema = Repository.load_schema name: collection.indexer.schema
			Indexer.index collection: collection, docs: docs, schema: schema 
		}
	end

	desc 'init', 'init kaban repository'
	def init
		
	end

	desc 'sync', 'fetch + map + reset + index'
	def sync
		fetch
		map
		reset
		index
	end

end

Kaban.start(ARGV)