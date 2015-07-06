require 'csv'

class FileCsvExtractor < BaseExtractor
  def extract(_collection, endpoint)
    output = []
    CSV.foreach(endpoint.file, headers: true, header_converters: :symbol) do |row|
      output << row.to_hash
    end
    puts "fetched #{output.length} docs"
    output
  end
end
