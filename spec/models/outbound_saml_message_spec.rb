require "spec_helper"
require "rails_helper"
require "models/outbound_saml_message"

describe OutboundSamlMessage do
  it "needs all attributes" do
    message = OutboundSamlMessage.new({})
    expect(message.valid?).to be false
    expect(message.errors.full_messages).to contain_exactly(
      "Location can't be blank",
      "Saml request can't be blank",
      "Relay state can't be blank",
      "Registration is not included in the list",
    )
  end

  it "is valid when all attributes are present" do
    hash = {
        "postEndpoint" => "some-location",
        "samlMessage" => "a-saml-request",
        "relayState" => "relay-state",
        "registration" => false,
    }
    message = OutboundSamlMessage.new(hash)
    expect(message).to be_valid
  end

  it "needs to convert to correct JSON" do
    hash = {
        "postEndpoint" => "some-location",
        "samlMessage" => "a-saml-request",
        "relayState" => "relay-state",
        "registration" => false,
    }
    json = {
        "location" => "some-location",
        "saml_request" => "a-saml-request",
        "relay_state" => "relay-state",
        "registration" => false,
    }
    message = OutboundSamlMessage.new(hash)
    expect(message.to_json).to eql(json.to_json)
  end
end
