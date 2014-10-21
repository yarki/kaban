module Indexer
  def self.reset(collection: collection)
    puts "reset '#{collection.name}'"
    elastic = Elasticsearch::Client.new(
      host: configatron.env.elastic.host,
      log: configatron.env.elastic.logging
    )

    begin
      elastic.indices.delete index: collection.name
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      # suppress
    end

    # http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/_multi_fields.html
    # http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/mapping-root-object-type.html
    elastic.indices.create index: collection.name, body: {
      mappings: {
        '_default_' => {
          dynamic_templates: [
            string_fields: {
              mapping: {
                type: 'multi_field',
                fields: {
                  raw: {
                    index: 'not_analyzed',
                    type: 'string'
                  },
                  '{name}' => {
                    index: 'analyzed',
                    type: 'string'
                  }
                }
              },
              match_mapping_type: 'string',
              match: '*'
            }
          ]
        }
      }
    }
  end

  def self.index(collection: collection, docs: docs)
    reset collection: collection
    puts "index '#{collection.name}'"
    elastic = Elasticsearch::Client.new(
      host: configatron.env.elastic.host,
      log: configatron.env.elastic.logging
    )
    body = docs.map do |doc|
      {
        index: {
          _index: collection.name,
          _type: collection.name,
          data: doc
        }
      }
    end
    elastic.bulk body: body
  end
end
