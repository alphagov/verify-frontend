require 'spec_helper'
require 'models/session_validator'
require 'models/session_validator/session_id_cookie_validator'
require 'models/session_validator/session_start_time_validator'
require 'models/session_validator/missing_cookies_validator'
require 'models/session_validator/no_cookies_validator'
require 'models/session_validator/validation'
require 'models/session_validator/successful_validation'
require 'models/session_validator/validation_failure'
require 'models/session_validator/transaction_simple_id_presence'
require 'models/cookie_names'
require 'active_support/core_ext/hash/except'
require 'active_support/core_ext/date_time'
require 'active_support/core_ext/integer/time'

describe SessionValidator do
  let(:cookies) {
    {
      CookieNames::SESSION_ID_COOKIE_NAME => 'my-session-id',
      CookieNames::SECURE_COOKIE_NAME => 'my-secure-cookie'
    }
  }

  let(:session) {
    {
      transaction_simple_id: 'simple-id'
    }
  }

  let(:session_expiry) { 2 }
  let(:session_validator) {
    SessionValidator.new(session_expiry)
  }

  it "will fail validation if there are no cookies" do
    validation = session_validator.validate({}, session)
    expect(validation).to_not be_ok
    expect(validation.type).to eql :no_cookies
    expect(validation.message).to eql "No session cookies can be found"
  end

  it 'will pass validation if all cookies and session keys are present' do
    session[:start_time] = DateTime.now
    validation = session_validator.validate(cookies, session)
    expect(validation).to be_ok
  end

  it 'will fail validation if start time not found in session' do
    validation = session_validator.validate(cookies, session)
    expect(validation).to_not be_ok
    expect(validation.type).to eql :something_went_wrong
    expect(validation.message).to eql 'start_time not in session'
  end

  it "will fail validation if secure cookie is missing" do
    filter_cookies = cookies.except(CookieNames::SECURE_COOKIE_NAME)
    validation = session_validator.validate(filter_cookies, session)
    expect(validation).to_not be_ok
    expect(validation.type).to eql :something_went_wrong
    expect(validation.message).to eql "The following cookies are missing: [#{CookieNames::SECURE_COOKIE_NAME}]"
  end

  it "will fail validation if session id cookie is missing" do
    filter_cookies = cookies.except(CookieNames::SESSION_ID_COOKIE_NAME)
    validation = session_validator.validate(filter_cookies, session)
    expect(validation).to_not be_ok
    expect(validation.type).to eql :something_went_wrong
    expect(validation.message).to eql "The following cookies are missing: [#{CookieNames::SESSION_ID_COOKIE_NAME}]"
  end

  it 'will fail validation if session id and secure cookie are missing' do
    filter_cookies = cookies.except(CookieNames::SESSION_ID_COOKIE_NAME).except(CookieNames::SECURE_COOKIE_NAME)
    validation = session_validator.validate(filter_cookies, session)
    expect(validation).to_not be_ok
    expect(validation.type).to eql :no_cookies
    expect(validation.message).to eql 'No session cookies can be found'
  end

  it 'will fail validation if session is expired' do
    session[:start_time] = session_expiry.hours.ago
    validation = session_validator.validate(cookies, session)
    expect(validation).to_not be_ok
    expect(validation.type).to eql :cookie_expired
    expect(validation.message).to eql 'session "my-session-id" has expired'
  end

  it 'will fail validation if session is expired and start time is stored in milliseconds' do
    session[:start_time] = (session_expiry.hours.ago.to_i * 1000).to_s
    validation = session_validator.validate(cookies, session)
    expect(validation).to_not be_ok
    expect(validation.type).to eql :cookie_expired
    expect(validation.message).to eql 'session "my-session-id" has expired'
  end

  it "will fail validation if session id cookie is set to 'no-current-session'" do
    cookies[CookieNames::SESSION_ID_COOKIE_NAME] = 'no-current-session'
    validation = session_validator.validate(cookies, session)
    expect(validation).to_not be_ok
    expect(validation.type).to eql :something_went_wrong
    expect(validation.message).to eql "Secure cookie was set to a deleted session value 'no-current-session', indicating a previously completed session."
  end

  it 'will fail validation if session is missing current transaction simple id' do
    session.delete(:transaction_simple_id)
    validation = session_validator.validate(cookies, session)
    expect(validation).to_not be_ok
    expect(validation.type).to eql :something_went_wrong
    expect(validation.message).to eql "Transaction simple ID can not be found in the user's session"
  end
end
