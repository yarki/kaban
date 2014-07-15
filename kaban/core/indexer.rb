module Indexer

	def Indexer.reset(collection: collection, schema: schema)
		puts "reset '#{collection.name}'"
		elastic = Elasticsearch::Client.new host: configatron.env.elastic.host, log: configatron.env.elastic.logging
		elastic.indices.delete index: collection.name rescue puts 'Not yet exists'
		elastic.indices.create index: collection.name, body: { 
			mappings: { 
				collection.name => { properties: schema.properties.to_h } 
			} 
		}   
	end

	def Indexer.index(collection: collection, docs: docs, schema: schema)
		puts "index '#{collection.name}'"
		elastic = Elasticsearch::Client.new host: configatron.env.elastic.host, log: configatron.env.elastic.logging
		docs.each { |doc|
  			elastic.index index: collection.name, type: collection.name, id: doc[schema.primary_key!], body: doc
		}
	end

end