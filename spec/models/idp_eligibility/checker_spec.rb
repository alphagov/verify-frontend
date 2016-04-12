require 'spec_helper'
require 'models/idp_eligibility/checker'
require 'set'

module IdpEligibility
  RSpec.describe Checker do
    let(:rules_repository) { double(:rules_repository) }
    let(:checker) { Checker.new(rules_repository) }

    context '#any?' do
      it 'should return true when user has evidence accepted by an idp' do
        allow(rules_repository).to receive(:rules).and_return('idp' => [[:mobile_phone]])
        user_evidence = [:mobile_phone]
        expect(checker.any?(user_evidence, ['idp'])).to be_truthy
      end

      it 'should return false when user does not have evidence accepted by any idp' do
        allow(rules_repository).to receive(:rules).and_return('idp' => [[:mobile_phone]])
        user_evidence = [:landline]
        expect(checker.any?(user_evidence, ['idp'])).to be_falsey
      end
    end
  end
end
