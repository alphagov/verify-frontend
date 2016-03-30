require 'spec_helper'
require 'models/idp_eligibility/checker'
module IdpEligibility
  describe Checker do
    describe '#idps_at_document_stage' do
      it 'should return false when no idp rules are set up' do
        checker = Checker.new
        user_docs = [:passport]
        expect(checker.any_for_documents?(user_docs)).to be_falsey
      end

      it 'should return false when user has no documents matching rules' do
        checker = Checker.new
        checker.add_rule('licence-accepting-idp', [:driving_licence])
        user_docs = []
        expect(checker.any_for_documents?(user_docs)).to be_falsey
      end

      it 'should return true when user has evidence accepted by an idp' do
        checker = Checker.new
        checker.add_rule('licence-accepting-idp', [:driving_licence])
        user_docs = [:driving_licence]
        expect(checker.any_for_documents?(user_docs)).to be_truthy
      end

      it 'should return true when user has no docs and idp accepts no docs' do
        checker = Checker.new
        checker.add_rule('no-doc-accepting-idp', [])
        user_docs = []
        expect(checker.any_for_documents?(user_docs)).to be_truthy
      end

      it 'should return false when user has a document that does not match rules' do
        checker = Checker.new
        checker.add_rule('licence-accepting-idp', [:driving_licence])
        user_docs = [:passport]
        expect(checker.any_for_documents?(user_docs)).to be_falsey
      end

      it 'should ignore non document stage requirements' do
        checker = Checker.new
        checker.add_rule('licence-accepting-idp', [:hat, :driving_licence])
        user_docs = [:driving_licence]
        expect(checker.any_for_documents?(user_docs)).to be_truthy
      end
    end
  end
end
