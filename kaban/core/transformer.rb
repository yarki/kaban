module Transformer

	def Transformer.map(collection: collection, raw_docs: raw_docs, mapping: mapping)
		puts "map '#{collection.name}' using '#{mapping.name}'"
		output = raw_docs.map { |raw_doc|
			mapped_doc = {}
			doc = Hashie::Mash.new(raw_doc)
			mapping.properties.each { |property, expression|
				begin
					mapped_doc[property] = eval(expression)
				rescue
					puts "eval() failure: #{property} = #{expression}"
					mapped_doc[property] = 'ERROR'
				end
			}
			mapped_doc
		}
		puts "mapped #{output.length} docs"
		output
	end

end