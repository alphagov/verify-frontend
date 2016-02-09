require 'spec_helper'
require 'models/cookie_validator'
require 'models/cookie_names'
require 'active_support/core_ext/hash/except'
require 'active_support/core_ext/date_time'
require 'active_support/core_ext/integer/time'

describe CookieValidator do
  let(:cookies) {
    {
      CookieNames::SESSION_STARTED_TIME_COOKIE_NAME => DateTime.now.to_i.to_s,
      CookieNames::SESSION_ID_COOKIE_NAME => "my-session-id",
      CookieNames::SECURE_COOKIE_NAME => "my-secure-cookie"
    }
  }

  it "will fail validation if there are no cookies" do
    validation = CookieValidator.new.validate({})
    expect(validation).to_not be_ok
    expect(validation.type).to eql :no_cookies
    expect(validation.message).to eql "No session cookies can be found"
  end

  it "will pass validation if all cookies are present" do
    validation = CookieValidator.new.validate(cookies)
    expect(validation).to be_ok
  end

  it "will fail validation if session start time cookie is missing" do
    filter_cookies = cookies.except(CookieNames::SESSION_STARTED_TIME_COOKIE_NAME)
    validation = CookieValidator.new.validate(filter_cookies)
    expect(validation).to_not be_ok
    expect(validation.type).to eql :something_went_wrong
    expect(validation.message).to eql "The following cookies are missing: [#{CookieNames::SESSION_STARTED_TIME_COOKIE_NAME}]"
  end

  it "will fail validation if secure cookie is missing" do
    filter_cookies = cookies.except(CookieNames::SECURE_COOKIE_NAME)
    validation = CookieValidator.new.validate(filter_cookies)
    expect(validation).to_not be_ok
    expect(validation.type).to eql :something_went_wrong
    expect(validation.message).to eql "The following cookies are missing: [#{CookieNames::SECURE_COOKIE_NAME}]"
  end

  it "will fail validation if session id cookie is missing" do
    filter_cookies = cookies.except(CookieNames::SESSION_ID_COOKIE_NAME)
    validation = CookieValidator.new.validate(filter_cookies)
    expect(validation).to_not be_ok
    expect(validation.type).to eql :something_went_wrong
    expect(validation.message).to eql "The following cookies are missing: [#{CookieNames::SESSION_ID_COOKIE_NAME}]"
  end

  it "will fail validation if session id and session start time cookie is missing" do
    filter_cookies = cookies.except(CookieNames::SESSION_ID_COOKIE_NAME).except(CookieNames::SESSION_STARTED_TIME_COOKIE_NAME)
    validation = CookieValidator.new.validate(filter_cookies)
    expect(validation).to_not be_ok
    expect(validation.type).to eql :something_went_wrong
    expect(validation.message).to eql "The following cookies are missing: [#{CookieNames::SESSION_STARTED_TIME_COOKIE_NAME}, #{CookieNames::SESSION_ID_COOKIE_NAME}]"
  end

  it "will fail validation if session id and secure cookie are missing" do
    filter_cookies = cookies.except(CookieNames::SESSION_ID_COOKIE_NAME).except(CookieNames::SECURE_COOKIE_NAME)
    validation = CookieValidator.new.validate(filter_cookies)
    expect(validation).to_not be_ok
    expect(validation.type).to eql :something_went_wrong
    expect(validation.message).to eql "The following cookies are missing: [#{CookieNames::SESSION_ID_COOKIE_NAME}, #{CookieNames::SECURE_COOKIE_NAME}]"
  end

  it "will fail validation if session start time and secure cookie are missing" do
    filter_cookies = cookies.except(CookieNames::SESSION_STARTED_TIME_COOKIE_NAME).except(CookieNames::SECURE_COOKIE_NAME)
    validation = CookieValidator.new.validate(filter_cookies)
    expect(validation).to_not be_ok
    expect(validation.type).to eql :something_went_wrong
    expect(validation.message).to eql "The following cookies are missing: [#{CookieNames::SESSION_STARTED_TIME_COOKIE_NAME}, #{CookieNames::SECURE_COOKIE_NAME}]"
  end

  it "will fail validation if session start time cookie can't be parsed" do
    filter_cookies = cookies.merge({CookieNames::SESSION_STARTED_TIME_COOKIE_NAME => "unparsable"})
    validation = CookieValidator.new.validate(filter_cookies)
    expect(validation).to_not be_ok
    expect(validation.type).to eql :something_went_wrong
    expect(validation.message).to eql "The session start time cookie, 'unparsable', can't be parsed"
  end

  it "will fail validation if session start time cookie is expired" do
    filter_cookies = cookies.merge({CookieNames::SESSION_STARTED_TIME_COOKIE_NAME => 2.hours.ago.to_i.to_s})
    validation = CookieValidator.new.validate(filter_cookies)
    expect(validation).to_not be_ok
    expect(validation.type).to eql :cookie_expired
    expect(validation.message).to eql 'session_start_time cookie for session "my-session-id" has expired'
  end
end
