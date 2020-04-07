require "spec_helper"
require "rails_helper"

describe IdpListResponse do
  it "is invalid when idps aren't valid" do
    federation = IdpListResponse.new([{}])
    expect(federation).to_not be_valid
    expect(federation.errors.full_messages).to include "Identity providers are malformed"
  end

  it "can be valid with an empty list of idps" do
    federation = IdpListResponse.new([])
    federation.valid?
    expect(federation.errors.full_messages).to_not include "Identity providers are malformed"
  end
end
