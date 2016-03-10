require 'spec_helper'
require 'configuration'

describe Configuration do
  it 'loads up env vars!' do
    expect(ENV).to receive(:fetch).with("FOOBAZ").and_return('foo')
    config = Configuration.load! do
      option_string 'foobaz', 'FOOBAZ'
    end
    expect(config.foobaz).to eql 'foo'
  end

  it 'will raise an error when the envvar is unset' do
    expect {
      Configuration.load! do
        option_string 'foobaz', 'FOOBAZ'
      end
    }.to raise_error Configuration::MissingEnvVarError, "An Environment Variable named 'FOOBAZ' could not be found"
  end

  it 'will not share config with other classes' do
    expect(ENV).to receive(:fetch).with("FOOBAZ").and_return('foo')
    Configuration.load! do
      option_string 'foobaz', 'FOOBAZ'
    end
    config = Configuration.load! do
    end
    expect { config.foobaz }.to raise_error NoMethodError
  end

  it 'should load a boolean environment variable' do
    expect(ENV).to receive(:fetch).with("FOOBAZ").and_return('true')
    config = Configuration.load! do
      option_bool 'foobaz', 'FOOBAZ'
    end
    expect(config.foobaz).to eql true
  end

  it 'should raise an error when boolean environment variable has invalid value' do
    expect(ENV).to receive(:fetch).with("FOOBAZ").and_return('bad value')
    expect {
      Configuration.load! do
        option_bool 'foobaz', 'FOOBAZ'
      end
    }.to raise_error Configuration::InvalidEnvVarError, "Boolean Environment Variable 'FOOBAZ' must be 'true' or 'false'"
  end

  it 'should load an integer environment variable' do
    expect(ENV).to receive(:fetch).with("FOOBAZ").and_return('10')
    config = Configuration.load! do
      option_int 'foobaz', 'FOOBAZ'
    end
    expect(config.foobaz).to eql 10
  end

  it 'should raise an error when integer environment variable has invalid value' do
    expect(ENV).to receive(:fetch).with("FOOBAZ").and_return('bad value')
    expect {
      Configuration.load! do
        option_int 'foobaz', 'FOOBAZ'
      end
    }.to raise_error Configuration::InvalidEnvVarError, "Integer Environment Variable 'FOOBAZ' must be a valid integer"
  end
end
