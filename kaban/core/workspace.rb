module Workspace
  def self.save_raw(docs: docs, collection: collection)
    raw_file = "#{configatron.workspace.staging}/#{collection.name}.fetched.json"
    puts "save raw to #{raw_file}"
    File.open(raw_file, 'w') do |f|
      f.write(JSON.pretty_generate(docs))
    end
  end

  def self.load_raw(collection: collection)
    raw_file = "#{configatron.workspace.staging}/#{collection.name}.fetched.json"
    puts "load raw from #{raw_file}"
    JSON.parse(File.read(raw_file))
  end

  def self.save_mapped(docs: docs, collection: collection)
    mapped_file = "#{configatron.workspace.staging}/#{collection.name}.mapped.json"
    puts "save mapped to #{mapped_file}"
    File.open(mapped_file, 'w') do |f|
      f.write(JSON.pretty_generate(docs))
    end
  end

  def self.load_mapped(collection: collection)
    mapped_file = "#{configatron.workspace.staging}/#{collection.name}.mapped.json"
    puts "load mapped from #{mapped_file}"
    JSON.parse(File.read(mapped_file))
  end
end
