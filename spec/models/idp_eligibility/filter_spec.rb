require 'spec_helper'
require 'idp_eligibility/filter'

module IdpEligibility
  describe Filter do
    it 'will filter idps that meet evidence using their simple id' do
      idp_one = double(:idp_one, simple_id: 'idp_one')
      idp_two = double(:idp_two, simple_id: 'idp_two')
      enabled_idps = [idp_one, idp_two]
      evidence = double(:evidence)
      rules = double(:rules)
      expect(rules).to receive(:idps_for).with(evidence).and_return(['idp_one'])
      filtered_idps = Filter.new.filter_idps(rules, evidence, enabled_idps)
      expect(filtered_idps).to eql [idp_one]
    end
  end
end
