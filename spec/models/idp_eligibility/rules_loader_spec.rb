require 'spec_helper'
require 'models/idp_eligibility/rules_loader'

module IdpEligibility
  describe RulesLoader do
    def fixtures(data = '')
      File.join('spec', 'fixtures', data)
    end

    describe '#load' do
      it 'should load rules from YAML files' do
        evidence = [%w(passport driving_licence)]
        rules_hash = {
          'example-idp' => evidence,
          'example-idp-stub' => evidence
        }
        expect(RulesLoader.load(fixtures('good_rules'))).to eql(rules_hash)
      end

      it 'should raise an error when expected keys are missing from yaml' do
        expect {
          RulesLoader.load(fixtures('bad_rules'))
        }.to raise_error KeyError
      end

      it 'should return an empty object when no yaml files found' do
        expect(RulesLoader.load(fixtures)).to eql({})
      end
    end
  end
end
