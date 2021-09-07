require "rails_helper"
require "controller_helper"
require "spec_helper"
require "api_test_helper"

describe MetadataController do
  subject { get :service_list, params: { locale: "en" } }

  it "JSON array should contain 4 objects with correct values" do
    stub_transactions_for_single_idp_list

    body = JSON.parse(subject.body)

    expect(body.size).to eq(3)
    expect(subject.content_type).to eq("application/json")
    expect(subject).to have_http_status(200)

    test_rp_object =
      body.find { |rp| rp["serviceId"] == "http://www.test-rp.gov.uk/SAML2/MD" }

    expect(test_rp_object.nil?).to be false
    expect(test_rp_object["name"]).to eq("test GOV.UK Verify user journeys")
    expect(test_rp_object["loa"]).to eq("LEVEL_2")
    expect(test_rp_object["serviceCategory"]).to eq("Benefits")

    another_test_rp_object =
      body.find { |rp| rp["serviceId"] == "some-other-entity-id" }

    expect(another_test_rp_object.nil?).to be false
    expect(another_test_rp_object["name"])
      .to eq("Test GOV.UK Verify user journeys (forceauthn & no cycle3)")
    expect(another_test_rp_object["loa"]).to eq("LEVEL_2")
    expect(another_test_rp_object["serviceCategory"]).to eq("Benefits")
  end
end
