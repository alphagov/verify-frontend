require "spec_helper"
require "rails_helper"
require "models/select_idp_response"

describe SelectIdpResponse do
  it "needs all attributes" do
    message = SelectIdpResponse.new({})
    expect(message.valid?).to be false
    expect(message.errors.full_messages).to contain_exactly("Encrypted entity can't be blank")
  end

  it "is valid when all attributes are present" do
    hash = {
        "encryptedEntityId" => "an-entity-id",
    }
    message = SelectIdpResponse.new(hash)
    expect(message).to be_valid
  end
end
