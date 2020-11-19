require "spec_helper"
require "idp_configuration/idp_feature_flags_loader"

module IdpConfiguration
  describe IdpFeatureFlagsLoader do
    let(:file_loader) { double(:file_loader) }
    let(:loader) {
      IdpFeatureFlagsLoader.new(file_loader)
    }
    let(:good_profiles) {
      [
          {
              "simpleIds" => %w(example-idp example-idp-stub),
              "flag_a" => "true",
              "non_declared_flag" => "true",
          },
          {
              "simpleIds" => %w(example-idp-two),
              "flag_b" => "true",
          },
      ]
    }
    let(:checker) {
      path = "good_profiles_path"
      expect(file_loader).to receive(:load).with(path).and_return(good_profiles)

      loader.load(path, %i[flag_a flag_b])
    }

    it "should return the feature flag checker from configuration" do
      expect(checker.enabled?(:flag_a, "example-idp")).to eql(true)
      expect(checker.enabled?(:flag_b, "example-idp")).to eql(false)
    end

    it "should return checker that ignores non declared flags" do
      expect(checker.enabled?(:non_declared_flag, "example-idp")).to eql(false)
    end
  end
end
