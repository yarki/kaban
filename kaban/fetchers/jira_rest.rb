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
	output = client.Issue.jql(query, nil, 0, 1000).map{ |issue|
		doc = {}
		doc['key'] = issue.key
		doc['id'] = issue.id
		doc['fields'] = issue.fields
		doc
	}
	puts "fetched #{output.length} docs"
	output
end