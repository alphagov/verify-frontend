require "rails_helper"
require "controller_helper"
require "spec_helper"
require "api_test_helper"

describe CompletedRegistrationController do
  let(:valid_idp_simple_id) { "stub-idp-one" }
  let(:entity_id) { "http://idcorp.com" }
  let(:transaction_id) { "https://wwwm.universal-credit.service.gov.uk" }

  context "#index" do
    it "renders the page when the IDP is valid" do
      cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = {
        value: { "RESUMELINK": { IDP: :valid_idp_simple_id } }.to_json,
        expires: 18.months.from_now,
      }

      stub_api_idp_list_for_sign_in_without_session(
        [
          { simpleId: "stub-idp-one",
            entityId: entity_id,
            levelsOfAssurance: [LevelOfAssurance::LOA2] },
        ],
        transaction_id,
      )

      get :index, params: { locale: "en", idp: valid_idp_simple_id }

      expect(subject).to render_template(:index)

      cookie_hint = MultiJson.load(cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT])

      expect(cookie_hint["ATTEMPT"]).to eq(entity_id)
      expect(cookie_hint["SUCCESS"]).to eq(entity_id)
      expect((cookie_hint.has_key? "RESUMELINK")).to be false
    end

    it "redirects to the verify services page and does not set the journey hint cookie if IDP invalid" do
      stub_transaction_details
      get :index, params: { locale: "en", idp: "invalid-idp" }
      expect(subject).to redirect_to verify_services_path

      expect(cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT]).to be_nil
    end
  end
end
