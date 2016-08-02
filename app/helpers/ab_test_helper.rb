module AbTestHelper
  def ab_test
    ::AB_TEST.alternative_name(cookies[CookieNames::AB_TEST])
  end
end
