module ClassLoader
  def self.create_instance(super_class, src_file)
    mod = Module.new { module_eval(File.read(src_file)) }
    fail "Only one class is allowed to be defined at #{src_file}" unless mod.constants.length == 1

    instance = mod.const_get(mod.constants.first).new
    fail "Unexpected superclass #{instance.class.superclass}" unless instance.class.superclass == super_class

    instance
  end
end
