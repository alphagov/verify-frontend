require 'spec_helper'
require 'models/cookie_validator'
require 'models/cookie_names'

describe CookieValidator do
  it "will fail validation if there are no cookies" do
    validation = CookieValidator.new.validate({})
    expect(validation).to be_no_cookies
    expect(validation).to_not be_ok
    expect(validation.message).to eql "No session cookies can be found"
  end

  it "will pass validation if all cookies are present" do
    cookies = Hash[CookieNames.session_cookies.collect { |n| [n, n] }]
    validation = CookieValidator.new.validate(cookies)
    expect(validation).to be_ok
    expect(validation).to_not be_no_cookies
  end
end
