require 'spec_helper'
require 'idp_eligibility/document_checker'
require 'set'

module IdpEligibility
  RSpec.describe DocumentChecker do
    let(:checker) { DocumentChecker.new(rules) }
    let(:singleton_idp) { [double(:idp, simple_id: 'idp')] }

    context '#any?' do
      it 'should return false when no idp rules are set up' do
        rules = {}
        checker = DocumentChecker.new(rules)
        user_docs = [:passport]
        expect(checker.any?(user_docs, singleton_idp)).to be_falsey
      end

      it 'should return false when user has no documents matching rules' do
        rules = { 'idp' => [[:driving_licence]] }
        checker = DocumentChecker.new(rules)
        user_docs = []
        expect(checker.any?(user_docs, singleton_idp)).to be_falsey
      end

      it 'should return true when user has evidence accepted by an idp' do
        rules = { 'idp' => [[:driving_licence]] }
        checker = DocumentChecker.new(rules)
        user_docs = [:driving_licence]
        expect(checker.any?(user_docs, singleton_idp)).to be_truthy
      end

      it 'should return true when user has no docs and idp accepts no docs' do
        rules = { 'idp' => [[]] }
        checker = DocumentChecker.new(rules)
        user_docs = []
        expect(checker.any?(user_docs, singleton_idp)).to be_truthy
      end

      it 'should return false when user has a document that does not match rules' do
        rules = { 'idp' => [[:driving_licence]] }
        checker = DocumentChecker.new(rules)
        user_docs = [:passport]
        expect(checker.any?(user_docs, singleton_idp)).to be_falsey
      end

      it 'should ignore non document stage requirements' do
        rules = { 'idp' => [[:hat, :driving_licence]] }
        checker = DocumentChecker.new(rules)
        user_docs = [:driving_licence]
        expect(checker.any?(user_docs, singleton_idp)).to be_truthy
      end

      it 'should work when no idps are provided' do
        rules = { 'idp' => [[:driving_licence]] }
        checker = DocumentChecker.new(rules)
        user_docs = [:driving_licence]
        expect(checker.any?(user_docs, [])).to be_falsey
      end
    end
  end
end
