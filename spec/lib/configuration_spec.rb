require "spec_helper"
require "configuration"

describe Configuration do
  it "loads up env vars!" do
    expect(ENV).to receive(:fetch).with("FOOBAZ").and_return("foo")
    config = Configuration.load! do
      option_string "foobaz", "FOOBAZ"
    end
    expect(config.foobaz).to eql "foo"
  end

  it "will raise an error when the envvar is unset" do
    expect {
      Configuration.load! do
        option_string "foobaz", "FOOBAZ"
      end
    }.to raise_error Configuration::MissingEnvVarError, "An Environment Variable named 'FOOBAZ' could not be found"
  end

  it "will fallback to a default if provided it" do
    config = Configuration.load! do
      option_string "foobaz", "FOOBAZ", default: "bar"
    end
    expect(config.foobaz).to eql "bar"
  end

  it "can be missing" do
    config = Configuration.load! do
      option_string "foobaz", "FOOBAZ", allow_missing: true
    end
    expect(config.foobaz).to eql nil
  end

  it "will not share config with other classes" do
    expect(ENV).to receive(:fetch).with("FOOBAZ").and_return("foo")
    Configuration.load! do
      option_string "foobaz", "FOOBAZ"
    end
    config = Configuration.load! do
    end
    expect { config.foobaz }.to raise_error NoMethodError
  end

  context "bools" do
    it "should load a boolean environment variable" do
      expect(ENV).to receive(:fetch).with("FOOBAZ").and_return("true")
      config = Configuration.load! do
        option_bool "foobaz", "FOOBAZ"
      end
      expect(config.foobaz).to eql true
    end

    it "should raise an error when boolean environment variable has invalid value" do
      expect(ENV).to receive(:fetch).with("FOOBAZ").and_return("bad value")
      expect {
        Configuration.load! do
          option_bool "foobaz", "FOOBAZ"
        end
      }.to raise_error Configuration::InvalidEnvVarError, "Boolean Environment Variable 'FOOBAZ' must be 'true' or 'false'"
    end

    it "will fallback to a default if provided it" do
      config = Configuration.load! do
        option_bool "foobaz", "FOOBAZ", default: true
      end
      expect(config.foobaz).to eql true
    end

    it "can't be missing" do
      expect {
        Configuration.load! do
          option_bool "foobaz", "FOOBAZ", allow_missing: true
        end
      }.to raise_error Configuration::InvalidEnvVarError, "Boolean Environment Variable 'FOOBAZ' must be 'true' or 'false'"
    end
  end

  context "datetime" do
    it "should parse a datetime string" do
      expect(ENV).to receive(:fetch).with("FOOBAZ").and_return("2020-12-31 22:59:59")
      config = Configuration.load! do
        option_datetime "foobaz", "FOOBAZ"
      end
      expect(config.foobaz).to eql DateTime.parse("2020-12-31 22:59:59")
    end

    it "should allow a missing datetime variable with allow_missing option" do
      config = Configuration.load! do
        option_datetime "foobaz", "FOOBAZ", allow_missing: true
      end
      expect(config.foobaz).to eql nil
    end

    it "should raise an error on a missing datetime variable with no allow_missing option" do
      expect {
        Configuration.load! do
          option_datetime "foobaz", "FOOBAZ"
        end
      }.to raise_error Configuration::MissingEnvVarError, "An Environment Variable named 'FOOBAZ' could not be found"
    end

    it "should log an error on a malformed datetime string and set value to nil" do
      expect(ENV).to receive(:fetch).with("FOOBAZ").and_return("not a datetime")
      allow(Rails.logger).to receive(:warn)
      expect(Rails.logger).to receive(:warn).with("DateTime Environment Variable 'FOOBAZ' must be a parseable DateTime i.e. '2020-12-31 22:59:59', given value was 'not a datetime'")
      config = Configuration.load! do
        option_datetime "foobaz", "FOOBAZ"
      end
      expect(config.foobaz).to eql nil
    end

    it "should log an error on a illegal datetime string and set value to nil" do
      expect(ENV).to receive(:fetch).with("FOOBAZ").and_return("2020-02-31 22:59:59")
      allow(Rails.logger).to receive(:warn)
      expect(Rails.logger).to receive(:warn).with("DateTime Environment Variable 'FOOBAZ' must be a parseable DateTime i.e. '2020-12-31 22:59:59', given value was '2020-02-31 22:59:59'")
      config = Configuration.load! do
        option_datetime "foobaz", "FOOBAZ"
      end
      expect(config.foobaz).to eql nil
    end
  end

  context "integers" do
    it "should load an integer environment variable" do
      expect(ENV).to receive(:fetch).with("FOOBAZ").and_return("10")
      config = Configuration.load! do
        option_int "foobaz", "FOOBAZ"
      end
      expect(config.foobaz).to eql 10
    end

    it "should raise an error when integer environment variable has invalid value" do
      expect(ENV).to receive(:fetch).with("FOOBAZ").and_return("bad value")
      expect {
        Configuration.load! do
          option_int "foobaz", "FOOBAZ"
        end
      }.to raise_error Configuration::InvalidEnvVarError, "Integer Environment Variable 'FOOBAZ' must be a valid integer"
    end

    it "will fallback to a default if provided it" do
      config = Configuration.load! do
        option_int "foobaz", "FOOBAZ", default: 10
      end
      expect(config.foobaz).to eql 10
    end

    it "can't be missing" do
      expect {
        Configuration.load! do
          option_int "foobaz", "FOOBAZ", allow_missing: true
        end
      }.to raise_error Configuration::InvalidEnvVarError, "Integer Environment Variable 'FOOBAZ' must be a valid integer"
    end
  end
end
