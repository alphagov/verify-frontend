require 'spec_helper'
require 'rails_helper'

describe SessionValidator do
  let(:cookies) {
    {
      CookieNames::SESSION_ID_COOKIE_NAME => 'my-session-id',
      CookieNames::SESSION_COOKIE_NAME => 'my-session-cookie'
    }
  }

  let(:session) {
    {
      transaction_simple_id: 'simple-id',
      requested_loa: 'LEVEL_1'
    }
  }

  let(:good_session) {
    {
      transaction_simple_id: 'simple-id',
      start_time: Time.now.to_i * 1000,
      verify_session_id: 'session_id',
      identity_providers: [{ 'simple_id' => 'stub-idp-one' }],
      requested_loa: 'LEVEL_1'
    }
  }

  let(:session_expiry) { 2 }
  let(:session_validator) {
    SessionValidator.new(session_expiry)
  }

  it 'will fail validation if there are no cookies' do
    validation = session_validator.validate({}, session)
    expect(validation).to_not be_ok
    expect(validation.type).to eql :no_cookies
    expect(validation.message).to eql 'No session cookies can be found'
  end

  it 'will pass validation if all cookies and session keys are present' do
    cookies[CookieNames::SESSION_ID_COOKIE_NAME] = 'session_id'
    session[:start_time] = Time.now.to_i * 1000
    session[:verify_session_id] = 'session_id'
    validation = session_validator.validate(cookies, session)
    expect(validation).to be_ok
  end

  it 'will fail validation if start time not found in session' do
    session[:verify_session_id] = 'session_id'
    cookies[CookieNames::SESSION_ID_COOKIE_NAME] = 'session_id'
    validation = session_validator.validate(cookies, session)
    expect(validation).to_not be_ok
    expect(validation.type).to eql :something_went_wrong
    expect(validation.message).to eql 'start_time not in session'
  end

  it 'will fail validation if session cookie is missing' do
    filter_cookies = cookies.except(CookieNames::SESSION_COOKIE_NAME)
    validation = session_validator.validate(filter_cookies, session)
    expect(validation).to_not be_ok
    expect(validation.type).to eql :something_went_wrong
    expect(validation.message).to eql "The following cookies are missing: [#{CookieNames::SESSION_COOKIE_NAME}]"
  end

  it 'will fail validation if session id cookie is missing' do
    filter_cookies = cookies.except(CookieNames::SESSION_ID_COOKIE_NAME)
    validation = session_validator.validate(filter_cookies, session)
    expect(validation).to_not be_ok
    expect(validation.type).to eql :something_went_wrong
    expect(validation.message).to eql "The following cookies are missing: [#{CookieNames::SESSION_ID_COOKIE_NAME}]"
  end

  it 'will fail validation if session id and session cookie are missing' do
    filter_cookies = cookies.except(CookieNames::SESSION_ID_COOKIE_NAME).except(CookieNames::SESSION_COOKIE_NAME)
    validation = session_validator.validate(filter_cookies, session)
    expect(validation).to_not be_ok
    expect(validation.type).to eql :no_cookies
    expect(validation.message).to eql 'No session cookies can be found'
  end

  it 'will fail validation if session is expired' do
    session[:start_time] = session_expiry.hours.ago.to_i * 1000
    session[:verify_session_id] = 'my-session-id'
    cookies[CookieNames::SESSION_ID_COOKIE_NAME] = 'my-session-id'
    validation = session_validator.validate(cookies, session)
    expect(validation).to_not be_ok
    expect(validation.type).to eql :cookie_expired
    expect(validation.message).to eql 'session "my-session-id" has expired'
  end

  it "will fail validation if session id in session is set to 'no-current-session'" do
    cookies[CookieNames::SESSION_ID_COOKIE_NAME] = 'session_id'
    session[:verify_session_id] = 'no-current-session'
    validation = session_validator.validate(cookies, session)
    expect(validation).to_not be_ok
    expect(validation.type).to eql :something_went_wrong
    expect(validation.message).to eql "Secure cookie was set to a deleted session value 'no-current-session', indicating a previously completed session."
  end

  it 'should return ValidationFailure when session id is not present' do
    cookies[CookieNames::SESSION_ID_COOKIE_NAME] = 'session_id'
    validation = session_validator.validate(cookies, session)
    expect(validation).to_not be_ok
    expect(validation.type).to eql :something_went_wrong
    expect(validation.message).to eql 'Session ID in the rails session is missing'
  end

  it 'should return ValidationFailure when session ids do not match' do
    cookies[CookieNames::SESSION_ID_COOKIE_NAME] = 'session_id_a'
    session[:verify_session_id] = 'session_id_b'
    session[:start_time] = Time.now.to_i * 1000
    validation = session_validator.validate(cookies, session)
    expect(validation).to_not be_ok
    expect(validation.type).to eql :something_went_wrong
    expect(validation.message).to eql 'Session ID in cookie does not match value in session'
  end

  it 'will fail validation if session is missing current transaction simple id' do
    session.delete(:transaction_simple_id)
    session[:verify_session_id] = 'session_id'
    cookies[CookieNames::SESSION_ID_COOKIE_NAME] = 'session_id'
    validation = session_validator.validate(cookies, session)
    expect(validation).to_not be_ok
    expect(validation.type).to eql :something_went_wrong
    expect(validation.message).to eql "Transaction simple ID can not be found in the user's session"
  end

  it 'will fail validation if session is missing requested level of assurance' do
    session = good_session
    session.delete(:requested_loa)
    session[:verify_session_id] = 'session_id'
    cookies[CookieNames::SESSION_ID_COOKIE_NAME] = 'session_id'
    validation = session_validator.validate(cookies, session)
    expect(validation).to_not be_ok
    expect(validation.type).to eql :something_went_wrong
    expect(validation.message).to eql "Requested LOA can not be found in the user's session"
  end

  it 'will log an error if the session cookie is getting too large' do
    cookies[CookieNames::SESSION_ID_COOKIE_NAME] = 'session_id'
    session = good_session
    session[:foo] = '1' * 3700
    logger = double(:logger)
    stub_const('Rails', double(:rails, logger: logger))
    expect(logger).to receive(:error).with(/Session cookie is large/)

    validation = session_validator.validate(cookies, session)

    expect(validation).to be_ok
  end
end
