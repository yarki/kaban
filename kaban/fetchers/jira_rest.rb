def fetch(collection: collection, endpoint: endpoint)
	super
	query = collection.fetcher.query
	puts "query: #{query}"
	options = {
	            :username => endpoint.username,
	            :password => endpoint.password,
	            :site     => endpoint.site,
	            :context_path => endpoint.context_path,
	            :auth_type => endpoint.auth_type,
	            :use_ssl => endpoint.use_ssl
	          }
	client = JIRA::Client.new(options)
	puts 'fetching...'
	output = []
	max_size = 1500
	chunk_size = 100
	iterations = max_size / chunk_size
	(1..iterations).each { |i|
		start_at = (i - 1) * chunk_size
		puts 'chunk %02d: %03d-%03d' % [i, start_at, start_at + chunk_size - 1]
		Retriable.retriable :on => JIRA::HTTPError, :tries => 3, :interval => 10 do
			client.Issue.jql(query, nil, start_at, chunk_size).map { |issue|
				doc = {}
				doc['key'] = issue.key
				doc['id'] = issue.id
				doc['fields'] = issue.fields
				doc
			}.each { |doc|
				output << doc
			}
		end
	}
	puts "fetched #{output.length} docs"
	output
end