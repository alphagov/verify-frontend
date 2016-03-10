class Configuration
  MissingEnvVarError = Class.new(StandardError)
  InvalidEnvVarError = Class.new(StandardError)
  def self.load!(&blk)
    config = Configuration.new
    config.instance_eval(&blk)
    config
  end

  def option_string(name, envvar)
    set_reader(name, fetch_env_var(envvar))
  end

  def option_int(name, envvar)
    value = Integer(fetch_env_var(envvar))
    set_reader(name, value)
  rescue ArgumentError
    raise InvalidEnvVarError, "Integer Environment Variable '#{envvar}' must be a valid integer"
  end

  def option_bool(name, envvar)
    value = case fetch_env_var(envvar)
            when 'true'
              true
            when 'false'
              false
            else
              raise InvalidEnvVarError, "Boolean Environment Variable '#{envvar}' must be 'true' or 'false'"
            end
    set_reader(name, value)
  end

private

  def fetch_env_var(envvar)
    ENV.fetch(envvar) do
      raise MissingEnvVarError, "An Environment Variable named '#{envvar}' could not be found"
    end
  end

  def set_reader(name, value)
    instance_variable_set("@#{name}", value)
    eigenclass = class << self;
      self;
    end
    eigenclass.class_eval { attr_reader name }
  end
end
