class BaseTransformer
  def initialize
    @output = []
  end

  def before_transform
  end

  def after_transform
    puts "#{@output.length} docs emitted"
  end

  def recieve(_doc)
  end

  def emit(doc)
    @output << doc
  end

  def transform(collection: collection, raw_docs: raw_docs)
    puts "transforming '#{collection.name}'"
    before_transform
    raw_docs.each { |doc| recieve(doc) }
    after_transform
    @output
  end
end
