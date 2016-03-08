class Configuration
  MissingEnvVarError = Class.new(StandardError)
  def self.load!(&blk)
    config = Configuration.new
    config.instance_eval(&blk)
    config
  end

  def option(name, envvar)
    value = ENV.fetch(envvar) do
      raise MissingEnvVarError, "An Environment Variable named '#{envvar}' could not be found"
    end
    instance_variable_set("@#{name}", value)
    eigenclass = class << self; self; end
    eigenclass.class_eval { attr_reader name }
  end
end
