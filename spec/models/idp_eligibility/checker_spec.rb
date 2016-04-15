require 'spec_helper'
require 'models/idp_eligibility/evidence'
require 'models/idp_eligibility/checker'
require 'set'

module IdpEligibility
  RSpec.describe Checker do
    let(:rules_repository) { double(:rules_repository) }
    let(:checker) { Checker.new(rules_repository) }
    let(:idp1) { double(:idp1, simple_id: 'idp') }
    let(:idp2) { double(:idp2, simple_id: 'idp2') }
    let(:singleton_idp) { [idp1] }
    let(:multiple_idps) { [idp1, idp2] }


    context '#any?' do
      it 'should return true when user has evidence accepted by an idp' do
        allow(rules_repository).to receive(:rules).and_return('idp' => [[:mobile_phone]])
        user_evidence = [:mobile_phone]
        expect(checker.any?(user_evidence, singleton_idp)).to be_truthy
      end

      it 'should return false when user does not have evidence accepted by any idp' do
        allow(rules_repository).to receive(:rules).and_return('idp' => [[:mobile_phone]])
        user_evidence = [:landline]
        expect(checker.any?(user_evidence, singleton_idp)).to be_falsey
      end
    end

    describe '#group_by_recommendation' do
      it 'should return recommended idps' do
        enabled_idps = singleton_idp
        allow(rules_repository).to receive(:rules).and_return('idp' => [[:passport]])
        user_docs = [:passport]
        grouped_idps = checker.group_by_recommendation(user_docs, enabled_idps)
        expect(grouped_idps.recommended).to eql(singleton_idp)
        expect(grouped_idps.non_recommended).to eql([])
      end

      it 'should return non-recommended idps' do
        enabled_idps = multiple_idps
        allow(rules_repository).to receive(:rules).and_return('idp' => [[:passport]], 'idp2' => [[:driving_licence]])
        user_docs = []
        grouped_idps = checker.group_by_recommendation(user_docs, enabled_idps)
        expect(grouped_idps.recommended).to eql([])
        expect(grouped_idps.non_recommended).to eql(multiple_idps)
      end

      it 'should return both recommended and non-recommended idps' do
        enabled_idps = multiple_idps
        allow(rules_repository).to receive(:rules).and_return('idp' => [[:passport]], 'idp2' => [[:driving_licence]])
        user_docs = [:driving_licence]
        grouped_idps = checker.group_by_recommendation(user_docs, enabled_idps)
        expect(grouped_idps.recommended).to eql([idp2])
        expect(grouped_idps.non_recommended).to eql([idp1])
      end

      it 'should return an empty list when no enabled idps' do
        enabled_idps = []
        allow(rules_repository).to receive(:rules).and_return({})
        user_docs = [:passport]
        grouped_idps = checker.group_by_recommendation(user_docs, enabled_idps)
        expect(grouped_idps.recommended).to eql([])
        expect(grouped_idps.non_recommended).to eql([])
      end
    end
  end
end
