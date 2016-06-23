require 'spec_helper'
require 'models/idp_eligibility/idp_hints_checker'

module IdpEligibility
  RSpec.describe IdpHintsChecker do
    it 'should say whether idp is enabled for hints' do
      idp_rules = %w(example-idp example-idp-two)
      checker = IdpHintsChecker.new(idp_rules)
      expect(checker.enabled?('example-idp')).to eql true
      expect(checker.enabled?('example-idp-two')).to eql true
    end

    it 'IdpHintsChecker.enabled? should return false if the simple id is not in the array' do
      idp_rules = []
      checker = IdpHintsChecker.new(idp_rules)
      expect(checker.enabled?('example-idp')).to eql false
    end
  end
end
