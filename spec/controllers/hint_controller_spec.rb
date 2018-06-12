require 'rails_helper'
require 'controller_helper'
require 'spec_helper'

describe HintController do
  subject { get :ajax_request, params: { locale: 'en' } }

  context 'user has a journey hint present' do
    it 'json object should return true' do
      cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = {
        'entity_id' => 'http://idcorp.com',
      }.to_json

      body = JSON.parse(subject.body)
      expect(body["value"]).to eq(true)
      expect(subject.content_type).to eq("application/json")
      expect(subject).to have_http_status(200)
    end

    it 'json object should return true even if the value is not set' do
      cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = {
        'entity_id' => '',
      }.to_json

      body = JSON.parse(subject.body)
      expect(body["value"]).to eq(true)
      expect(subject.content_type).to eq("application/json")
      expect(subject).to have_http_status(200)
    end
  end

  context 'user does not have a journey hint present' do
    it 'json object should return false' do
      body = JSON.parse(subject.body)
      expect(body["value"]).to eq(false)
      expect(subject.content_type).to eq("application/json")
      expect(subject).to have_http_status(200)
    end
  end
end
