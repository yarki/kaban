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
	chunk_size = 100
	start_at = 0
	i = 0
	loop {
		start_at = i * chunk_size
		puts 'chunk %03d: %04d-%04d' % [i, start_at, start_at + chunk_size - 1]
		result = []
		Retriable.retriable :on => JIRA::HTTPError, :tries => 3, :interval => 10 do
			result = client.Issue.jql(query, nil, start_at, chunk_size).map { |issue|
				doc = {}
				doc['key'] = issue.key
				doc['id'] = issue.id
				doc['fields'] = issue.fields
				doc
			}
		end
		break if result.empty?
		output = output.concat(result)
		break if result.length < chunk_size
		i += 1
	}
	puts "fetched #{output.length} docs"
	output
end