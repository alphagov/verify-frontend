require 'spec_helper'
require 'idp_eligibility/checker'
require 'idp_eligibility/rules_repository'
require 'idp_eligibility/profile'
require 'set'

module IdpEligibility
  RSpec.describe Checker do
    let(:idp1) { double(:idp1, simple_id: 'idp') }
    let(:idp2) { double(:idp2, simple_id: 'idp2') }
    let(:singleton_idp) { [idp1] }
    let(:multiple_idps) { [idp1, idp2] }


    context '#any?' do
      it 'should return true when user has evidence accepted by an idp' do
        rules_repository = RulesRepository.new('idp' => [Profile.new([:mobile_phone])])
        user_evidence = [:mobile_phone]
        expect(Checker.new(rules_repository).any?(user_evidence, singleton_idp)).to be_truthy
      end

      it 'should return false when user does not have evidence accepted by any idp' do
        rules_repository = RulesRepository.new('idp' => [Profile.new([:mobile_phone])])
        user_evidence = [:landline]
        expect(Checker.new(rules_repository).any?(user_evidence, singleton_idp)).to be_falsey
      end
    end
  end
end
