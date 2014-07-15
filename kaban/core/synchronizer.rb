module Synchronizer

	def Synchronizer.load_fetcher(name: name)
		fetcher_file = "#{configatron.core.fetchers}/#{name}.rb"
		fetcher = Fetcher.new
		fetcher.instance_eval(File.read(fetcher_file))
		fetcher
	end
	
	def Synchronizer.fetch(collection: collection)
		fetcher = load_fetcher name: collection.fetcher.name
		endpoint = Repository.load_endpoint name: collection.fetcher.endpoint
		puts "fetch '#{collection.name}' from '#{endpoint.name}'"
		fetcher.fetch collection: collection, endpoint: endpoint
	end

end