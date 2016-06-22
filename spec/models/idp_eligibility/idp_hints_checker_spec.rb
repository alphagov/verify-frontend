require 'spec_helper'
require 'models/idp_eligibility/rules_repository'
require 'models/idp_eligibility/idp_hints_checker'

module IdpEligibility
  RSpec.describe IdpHintsChecker do
    it 'should say whether idp is enabled for hints' do
      idp_rules = {
        'example-idp' => { rules: [[]], send_hints: true },
        'example-idp-two' => { rules: [[]], send_hints: false },
      }
      checker = IdpHintsChecker.new(idp_rules)
      expect(checker.enabled?('example-idp')).to eql true
      expect(checker.enabled?('example-idp-two')).to eql false
    end

    it 'IdpHintsChecker.enabled? should return false if send_hints is absent' do
      idp_rules = {
        'example-idp' => { rules: [[]] }
      }
      checker = IdpHintsChecker.new(idp_rules)
      expect(checker.enabled?('example-idp')).to eql false
    end

    it 'IdpHintsChecker.enabled? should return false if the idp id is not found' do
      idp_rules = {
        'example-idp' => { rules: [[]] }
      }
      checker = IdpHintsChecker.new(idp_rules)
      expect(checker.enabled?('not-the-example-idp')).to eql false
    end
  end
end
