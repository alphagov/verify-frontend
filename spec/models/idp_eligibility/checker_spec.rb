require 'spec_helper'
require 'models/idp_eligibility/checker'
module IdpEligibility
  describe Checker do
    let(:rules_repository) { double(:rules_repository) }
    before(:each) { @checker = Checker.new(rules_repository) }

    describe '#any?' do
      it 'should return true when user has evidence accepted by an idp' do
        allow(rules_repository).to receive(:rules).and_return('idp' => [[:mobile_phone]])
        user_evidence = [:mobile_phone]
        expect(@checker.any?(user_evidence, ['idp'])).to be_truthy
      end

      it 'should return false when user does not have evidence accepted by any idp' do
        allow(rules_repository).to receive(:rules).and_return('idp' => [[:mobile_phone]])
        user_evidence = [:landline]
        expect(@checker.any?(user_evidence, ['idp'])).to be_falsey
      end
    end

    describe '#any_for_documents?' do
      it 'should return false when no idp rules are set up' do
        allow(rules_repository).to receive(:rules).and_return({})
        user_docs = [:passport]
        expect(@checker.any_for_documents?(user_docs, ['idp'])).to be_falsey
      end

      it 'should return false when user has no documents matching rules' do
        allow(rules_repository).to receive(:rules).and_return('licence-accepting-idp' => [[:driving_licence]])
        user_docs = []
        expect(@checker.any_for_documents?(user_docs, ['licence-accepting-idp'])).to be_falsey
      end

      it 'should return true when user has evidence accepted by an idp' do
        allow(rules_repository).to receive(:rules).and_return('licence-accepting-idp' => [[:driving_licence]])
        user_docs = [:driving_licence]
        expect(@checker.any_for_documents?(user_docs, ['licence-accepting-idp'])).to be_truthy
      end

      it 'should return true when user has no docs and idp accepts no docs' do
        allow(rules_repository).to receive(:rules).and_return('no-doc-accepting-idp' => [[]])
        user_docs = []
        expect(@checker.any_for_documents?(user_docs, ['no-doc-accepting-idp'])).to be_truthy
      end

      it 'should return false when user has a document that does not match rules' do
        allow(rules_repository).to receive(:rules).and_return('licence-accepting-idp' => [[:driving_licence]])
        user_docs = [:passport]
        expect(@checker.any_for_documents?(user_docs, ['licence-accepting-idp'])).to be_falsey
      end

      it 'should ignore non document stage requirements' do
        allow(rules_repository).to receive(:rules).and_return('licence-accepting-idp' => [[:hat, :driving_licence]])
        user_docs = [:driving_licence]
        expect(@checker.any_for_documents?(user_docs, ['licence-accepting-idp'])).to be_truthy
      end

      it 'should work when no idps are enabled' do
        enabled_idps = []
        allow(rules_repository).to receive(:rules).and_return('no-doc-accepting-idp' => [[]])
        user_docs = []
        expect(@checker.any_for_documents?(user_docs, enabled_idps)).to be_falsey
      end

      it 'should exclude idps that are not enabled' do
        enabled_idps = ['idp']
        allow(rules_repository).to receive(:rules).and_return('no-doc-accepting-idp' => [[]])
        user_docs = []
        expect(@checker.any_for_documents?(user_docs, enabled_idps)).to be_falsey
      end
    end
  end
end
