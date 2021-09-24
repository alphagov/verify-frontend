require "rails_helper"

RSpec.describe IdentityProviderRequest, skip_before: true do
  it "should wrap a saml request" do
    saml_message = OutboundSamlMessage.new(
      "postEndpoint" => "some_location",
      "samlMessage" => "some_request",
      "relayState" => "some_state",
      "registration" => "some_reg",
    )

    request = IdentityProviderRequest.new(saml_message)

    expect(request.location).to eql("some_location")
    expect(request.saml_request).to eql("some_request")
    expect(request.relay_state).to eql("some_state")
    expect(request.registration).to eql("some_reg")
  end
end
