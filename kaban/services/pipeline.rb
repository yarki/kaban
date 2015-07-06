module Pipeline
  def self.create_extractor(name)
    extractor_file = "#{configatron.core.extractors}/#{name}.rb"
    ClassLoader.create_instance(BaseExtractor, extractor_file)
  end

  def self.extract(collection)
    puts "extract '#{collection.name}' from '#{collection.extract.endpoint}' using '#{collection.extract.extractor}'"

    extractor = create_extractor(collection.extract.extractor)
    endpoint = Repository.load_endpoint name: collection.extract.endpoint

    docs = extractor.extract(collection, endpoint)
    Workspace.save_raw docs: docs, collection: collection
  end

  def self.transform(collection)
    puts "transform '#{collection.name}' using '#{collection.transform.transformer}'"
    raw_docs = Workspace.load_raw collection: collection

    transformer = Repository.load_transformer(name: collection.transform.transformer)
    docs = transformer.transform collection: collection, raw_docs: raw_docs
    Workspace.save_mapped collection: collection, docs: docs
  end

  def self.load(collection)
    puts "load '#{collection.name}'"
    docs = Workspace.load_mapped collection: collection
    Indexer.index collection: collection, docs: docs
  end
end
