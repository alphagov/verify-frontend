require 'spec_helper'
require 'rails_helper'

module Display
  module Federation
    describe FederationInfoGetter do
      it 'will return a list of IDPs for Displaying in an idp picker' do
        cookie_jar = double(:cookie_jar)
        session_proxy = double(:session_proxy)
        idp_display_correlator = double(:idp_display_correlator)

        idp_list = double(:idp_list)
        federation_info = FederationInfoResponse.new('idps' => idp_list, 'transactionEntityId' => 'blah')
        idp_display_data = double(:idp_display_data)

        federation_info_getter = FederationInfoGetter.new(session_proxy, idp_display_correlator)
        expect(session_proxy).to receive(:federation_info_for_session).with(cookie_jar).and_return(federation_info)
        expect(idp_display_correlator).to receive(:correlate).with(idp_list).and_return(idp_display_data)
        expect(idp_list).to receive(:shuffle).and_return(idp_list)

        hash = federation_info_getter.get_info(cookie_jar)
        expect(hash[:idp_display_data]).to eql(idp_display_data)
        expect(hash[:transaction_entity_id]).to eql('blah')
      end
    end
  end
end
