require 'models/display/idp/identity_provider_lister'

module Display
  module Idp
    describe IdentityProviderLister do
      it 'will return a list of IDPs for Displaying in an idp picker' do
        cookie_jar = double(:cookie_jar)
        session_proxy = double(:session_proxy)
        idp_display_correlator = double(:idp_display_correlator)

        idp_list = double(:idp_list)
        idp_display_data = double(:idp_display_data)
        logo_directory = 'stub-logos/'

        lister = IdentityProviderLister.new(session_proxy, idp_display_correlator)
        expect(session_proxy).to receive(:idps_for_session).with(cookie_jar).and_return(idp_list)
        expect(idp_display_correlator).to receive(:correlate).with(idp_list, logo_directory).and_return(idp_display_data)
        expect(idp_list).to receive(:shuffle).and_return(idp_list)

        result = lister.list(cookie_jar, logo_directory)
        expect(result).to eql(idp_display_data)
      end
    end
  end
end
