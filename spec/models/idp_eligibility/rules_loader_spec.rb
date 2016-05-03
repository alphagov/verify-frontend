require 'spec_helper'
require 'idp_eligibility/rules_repository'
require 'idp_eligibility/rules_loader'

module IdpEligibility
  describe RulesLoader do
    def fixtures(data = '')
      File.join('spec', 'fixtures', data)
    end

    describe '#load' do
      it 'should load recommended rules from YAML files' do
        evidence = [%i(passport driving_licence)]
        rules_repository = RulesRepository.new(
          'example-idp' => evidence,
          'example-idp-two' => evidence,
          'example-idp-stub' => evidence
        )
        expect(RulesLoader.new(fixtures('good_rules')).load.recommended_rules).to eq(rules_repository)
      end

      it 'should load non recommended rules from YAML files' do
        evidence = [%i(passport mobile_phone)]
        rules_repository = RulesRepository.new(
          'example-idp' => evidence,
          'example-idp-stub' => evidence,
          'example-idp-two' => [],
        )
        expect(RulesLoader.new(fixtures('good_rules')).load.non_recommended_rules).to eq(rules_repository)
      end

      it 'should load all rules from YAML files' do
        evidence = [%i{passport driving_licence}, %i(passport mobile_phone)]
        rules_repository = RulesRepository.new(
          'example-idp' => evidence,
          'example-idp-stub' => evidence,
          'example-idp-two' => [%i{passport driving_licence}]
        )
        expect(RulesLoader.new(fixtures('good_rules')).load.all_rules).to eq(rules_repository)
      end

      it 'should supply a seperate repository of document rules' do
        evidence = [%i{passport driving_licence}, %i(passport)]
        rules_repository = RulesRepository.new(
          'example-idp' => evidence,
          'example-idp-stub' => evidence,
          'example-idp-two' => [%i{passport driving_licence}]
        )
        expect(RulesLoader.new(fixtures('good_rules')).load.document_rules).to eq(rules_repository)
      end

      it 'should raise an error when expected keys are missing from yaml' do
        expect {
          RulesLoader.new(fixtures('bad_rules')).load
        }.to raise_error KeyError
      end

      it 'should return an empty object when no yaml files found' do
        expect(RulesLoader.new(fixtures).load.all_rules).to eq(RulesRepository.new({}))
      end

      it 'should return the hints configuration' do
        expected_hints = ['example-idp', 'example-idp-stub']
        expect(RulesLoader.new(fixtures('good_rules')).load.idps_with_hints).to eql(expected_hints)
      end
    end
  end
end
