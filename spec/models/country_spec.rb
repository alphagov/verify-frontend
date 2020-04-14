require "rails_helper"

RSpec.describe Country do
  it "is valid when simple_id and entity_id are provided" do
    country = Country.new("entity_id" => "entityId1", "simple_id" => "simpleId1", "enabled" => "enabled")
    expect(country).to be_valid
  end
end
