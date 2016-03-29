require 'spec_helper'
require 'models/idp_checker'

describe IdpChecker do
  describe '#idps_at_document_stage' do
    it 'should return no matches with no rules' do
      checker = IdpChecker.new
      user_docs = [:passport]
      matches = checker.idps_at_document_stage(user_docs)
      expect(matches).to eql []
    end

    it 'should return no matches when user has no documents matching rules' do
      checker = IdpChecker.new
      checker.add_rule('licence-accepting-idp', [:licence])
      user_docs = []
      matches = checker.idps_at_document_stage(user_docs)
      expect(matches).to eql []
    end

    it 'should return licence-accepting-idp when user has licence' do
      checker = IdpChecker.new
      checker.add_rule('licence-accepting-idp', [:licence])
      user_docs = [:licence]
      matches = checker.idps_at_document_stage(user_docs)
      expect(matches).to eql ['licence-accepting-idp']
    end

    it 'should return no matches when user has a document that does not match rules' do
      checker = IdpChecker.new
      checker.add_rule('licence-accepting-idp', [:licence])
      user_docs = [:passport]
      matches = checker.idps_at_document_stage(user_docs)
      expect(matches).to eql []
    end

    it 'should ignore non doc requirements' do
      checker = IdpChecker.new
      checker.add_rule('licence-accepting-idp', [:smart_phone, :licence])
      user_docs = [:licence]
      matches = checker.idps_at_document_stage(user_docs)
      expect(matches).to eql ['licence-accepting-idp']
    end
  end
end