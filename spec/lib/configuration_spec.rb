require 'spec_helper'
require 'configuration'

describe Configuration do
  it "loads up env vars!" do
    expect(ENV).to receive(:fetch).with("FOOBAZ").and_return('foo')
    config = Configuration.load! do
      option 'foobaz', 'FOOBAZ'
    end
    expect(config.foobaz).to eql 'foo'
  end

  it "will raise an error when the envvar is unset" do
    expect {
      Configuration.load! do
        option 'foobaz', 'FOOBAZ'
      end
    }.to raise_error Configuration::MissingEnvVarError, "An Environment Variable named 'FOOBAZ' could not be found"
  end

  it "will not share config with other classes" do
    expect(ENV).to receive(:fetch).with("FOOBAZ").and_return('foo')
    Configuration.load! do
      option 'foobaz', 'FOOBAZ'
    end
    config = Configuration.load! do
    end
    expect { config.foobaz }.to raise_error NoMethodError
  end
end
