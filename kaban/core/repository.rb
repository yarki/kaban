module Repository
	
	def Repository.collections
		Dir["#{configatron.repository.collections}/*.yml"].map { |file| load_collection file: file }
	end

	def Repository.load_collection(file: file)
		Hashie::Mash.load(file)
	end

	def Repository.load_schema(name: name)
		Hashie::Mash.load("#{configatron.repository.schemas}/#{name}.yml")
	end

	def Repository.load_mapping(name: name)
		Hashie::Mash.load("#{configatron.repository.mappings}/#{name}.yml")
	end

	def Repository.load_endpoint(name: name)
		endpoint_file = "#{configatron.repository.endpoints}/#{name}.yml"
		override_file = "#{configatron.repository.endpoints}/#{name}.yml.local"
		endpoint = Hashie::Mash.load(endpoint_file)
		endpoint = endpoint.merge Hashie::Mash.load(override_file) if File.exist?(override_file)
		endpoint
	end
	
end