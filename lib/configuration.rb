class Configuration
  MissingEnvVarError = Class.new(StandardError)
  InvalidEnvVarError = Class.new(StandardError)
  def self.load!(&blk)
    config = Configuration.new
    config.instance_eval(&blk)
    config
  end

  def option_string(name, envvar, options = {})
    option(name, envvar, options)
  end

  def option_int(name, envvar, options = {})
    option(name, envvar, options) do |value|
      begin
        Integer(value)
      rescue ArgumentError
        raise InvalidEnvVarError, "Integer Environment Variable '#{envvar}' must be a valid integer"
      end
    end
  end

  def option_bool(name, envvar, options = {})
    option(name, envvar, options) do |value|
      case value
      when 'true'
        true
      when 'false'
        false
      else
        raise InvalidEnvVarError, "Boolean Environment Variable '#{envvar}' must be 'true' or 'false'"
      end
    end
  end

private

  def option(name, envvar, options = {})
    env_value = fetch_env_var(envvar, options)
    value = block_given? ? yield(env_value.to_s) : env_value
    set_reader(name, value)
  end

  def fetch_env_var(envvar, options = {})
    ENV.fetch(envvar) do
      options.fetch(:default) {
        if options[:allow_missing]
          nil
        else
          raise MissingEnvVarError, "An Environment Variable named '#{envvar}' could not be found"
        end
      }
    end
  end

  def set_reader(name, value)
    instance_variable_set("@#{name}", value)
    eigenclass = class << self;
      self;
    end
    eigenclass.class_eval { attr_reader name }
    Rails.logger.debug("Config being set: Name: #{name}, Value: #{value}")
  end
end
