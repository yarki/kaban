module Repository
  def self.collections(name: name)
    Dir["#{configatron.repository.collections}/*.yml"]
      .map { |file| load_collection file: file }
      .select { |collection| (collection.name == name) || name.nil? }
  end

  def self.load_collection(file: file)
    Hashie::Mash.load(file)
  end

  def self.load_mapping(name: name)
    Hashie::Mash.load("#{configatron.repository.mappings}/#{name}.yml")
  end

  def self.load_endpoint(name: name)
    endpoint_file = "#{configatron.repository.endpoints}/#{name}.yml"
    override_file = "#{configatron.repository.endpoints}/#{name}.yml.local"
    endpoint = Hashie::Mash.load(endpoint_file)
    endpoint = endpoint.merge Hashie::Mash.load(override_file) if File.exist?(override_file)
    endpoint
  end
end
