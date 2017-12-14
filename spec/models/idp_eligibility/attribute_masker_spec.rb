require 'spec_helper'
require 'idp_eligibility/attribute_masker'

module IdpEligibility
  RSpec.describe AttributeMasker do
    it 'applies a mask of whitelisted attributes to every rule contained within an exisiting repository' do
      mask = %w{passport driving_licence}
      unmasked = {
        'idp_one' => [%w{passport mobile_phone}, %w{driving_licence}, %w{mobile_phone}],
        'idp_two' => [%w{passport driving_licence}, %w{mobile_phone smart_phone}]
      }
      expected = {
        'idp_one' => [%w{passport}, %w{driving_licence}, []],
        'idp_two' => [%w{passport driving_licence}, []]
      }
      expect(AttributeMasker.new(mask).mask(unmasked)).to eql expected
    end
  end
end
