module Indexer

	def Indexer.reset(collection: collection, schema: schema)
		puts "reset '#{collection.name}'"
		elastic = Elasticsearch::Client.new host: configatron.env.elastic.host, log: configatron.env.elastic.logging
		elastic.indices.delete index: collection.name rescue puts 'Not yet exists'
		
		# http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/_multi_fields.html
		prop_mapping = Hashie::Mash.new
		schema.properties.each { |prop, meta|
			prop_mapping[prop] = {
				type: meta.type,
				fields: {
					raw: {type: meta.type, index: 'not_analyzed'}
				}
			}
		}
	
		elastic.indices.create index: collection.name, body: {
			mappings: {
				collection.name => { properties: prop_mapping }
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