module Repository
  module Collections
    def self.find(collection_name)
      Hashie::Mash.load("#{configatron.repository.collections}/#{collection_name}.yml")
    end
  end

  def self.find_collection(name: name)
    Hashie::Mash.load("#{configatron.repository.collections}/#{name}.yml")
  end

  def self.collections(name: name)
    Dir["#{configatron.repository.collections}/*.yml"]
      .map { |file| load_collection file: file }
      .select { |collection| (collection.name == name) || name.nil? }
  end

  def self.select_collections(mask)
    Dir["#{configatron.repository.collections}/#{mask}.yml"]
      .map { |file| load_collection file: file }
  end

  def self.load_collection(file: file)
    Hashie::Mash.load(file)
  end

  def self.load_mapping(name: name)
    Hashie::Mash.load("#{configatron.repository.mappings}/#{name}.yml")
  end

  def self.load_transformer(name: name)
    transformer_file = "#{configatron.repository.transformers}/#{name}.rb"
    ClassLoader.create_instance(BaseTransformer, transformer_file)
  end

  def self.load_endpoint(name: name)
    endpoint_file = "#{configatron.repository.endpoints}/#{name}.yml"
    override_file = "#{configatron.repository.endpoints}/#{name}.yml.local"
    endpoint = Hashie::Mash.load(endpoint_file)
    endpoint = endpoint.merge Hashie::Mash.load(override_file) if File.exist?(override_file)
    endpoint
  end

  def self.find_endpoint(name: name)
    endpoint_file = "#{configatron.repository.endpoints}/#{name}.yml"
    override_file = "#{configatron.repository.endpoints}/#{name}.yml.local"
    endpoint = Hashie::Mash.load(endpoint_file)
    endpoint = endpoint.merge Hashie::Mash.load(override_file) if File.exist?(override_file)
    endpoint
  end
end
