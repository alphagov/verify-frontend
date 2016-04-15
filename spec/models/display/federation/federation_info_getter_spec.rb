require 'spec_helper'
require 'rails_helper'

module Display
  module Federation
    describe FederationInfoGetter do
      it 'will return a list of IDPs along with transaction entity and simple id' do
        cookie_jar = double(:cookie_jar)
        session_proxy = double(:session_proxy)
        idp_display_correlator = double(:idp_display_correlator)

        idp_list = [{ 'simpleId' => 'idp', 'entityId' => 'something' }]
        transaction_simple_id = 'simple_id_blah'
        transaction_entity_id = 'entity_id_blah'
        federation_info = double(:federation_info)
        idp_display_data = double(:idp_display_data)

        federation_info_getter = FederationInfoGetter.new(session_proxy, idp_display_correlator)
        expect(session_proxy).to receive(:federation_info_for_session).with(cookie_jar).and_return(federation_info)
        expect(federation_info).to receive(:idps).and_return(idp_list)
        expect(federation_info).to receive(:transaction_simple_id).and_return(transaction_simple_id)
        expect(federation_info).to receive(:transaction_entity_id).and_return(transaction_entity_id)
        expect(idp_list).to receive(:shuffle).and_return(idp_list)
        expect(idp_display_correlator).to receive(:correlate).with(idp_list).and_return(idp_display_data)

        hash = federation_info_getter.get_info(cookie_jar)
        expect(hash[:idp_display_data]).to eql(idp_display_data)
        expect(hash[:transaction_entity_id]).to eql(transaction_entity_id)
        expect(hash[:transaction_simple_id]).to eql(transaction_simple_id)
      end
    end
  end
end
