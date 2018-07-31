require 'rails_helper'
require 'controller_helper'
require 'spec_helper'

describe MetadataController do
  subject { get :service_list, params: { locale: 'en' } }

  it 'json array should contain 2 objects with correct values (as defined in api_test_helper stubs)' do
    body = JSON.parse(subject.body)

    expect(body.size).to eq(2)
    expect(subject.content_type).to eq("application/json")
    expect(subject).to have_http_status(200)

    test_rp_object = body.find { |rp| rp["simpleId"] == "test-rp" }

    expect(test_rp_object.nil?).to be false
    expect(test_rp_object["name"]).to eq("register for an identity profile")
    expect(test_rp_object["loa"]).to eq("LEVEL_2")
    expect(test_rp_object["taxon"]).to eq("Benefits")

    loa1_test_rp_object = body.find { |rp| rp["simpleId"] == "test-rp-noc3" }

    expect(loa1_test_rp_object.nil?).to be false
    expect(loa1_test_rp_object["name"]).to eq("Register for an identity profile (forceauthn & no cycle3)")
    expect(loa1_test_rp_object["loa"]).to eq("LEVEL_2")
    expect(loa1_test_rp_object["taxon"]).to eq("Benefits")
  end
end
