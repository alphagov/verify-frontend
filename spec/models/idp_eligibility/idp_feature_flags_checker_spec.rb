require 'spec_helper'
require 'models/idp_eligibility/idp_feature_flags_checker'

module IdpEligibility
  RSpec.describe IdpFeatureFlagsChecker do
    let(:feature_flags) {
      {
          flag_a: %w(idp_a idp_b),
          flag_b: %w(idp_b idp_c)
      }
    }
    let(:checker) { IdpFeatureFlagsChecker.new(feature_flags) }

    it 'should have flag enabled for existing flag' do
      expect(checker.enabled?(:flag_a, 'idp_a')).to be_truthy
    end

    it "should not have flag enabled if idp doesn't have flag set" do
      expect(checker.enabled?(:flag_a, 'idp_c')).to be_falsey
    end

    it 'should not have flag enabled for non-existent flag' do
      expect(checker.enabled?(:non_existent_flag, 'idp_a')).to be_falsey
    end

    it 'should not have flag enabled for non-existent idp' do
      expect(checker.enabled?(:flag_a, 'non_existent_idp')).to be_falsey
    end
  end
end
