class AboutController < ApplicationController
  include AbTestHelper
  layout 'slides', except: [:choosing_a_company]

  def index
    FEDERATION_REPORTER.report_registration(
      current_transaction,
      request
    )
    AbTest.report('rp_slides', ab_test('rp_slides'), request)
    @tailored_text = current_transaction.tailored_text
    @is_in_b_group = is_in_b_group_rp_slides?
  end

  def certified_companies
    @identity_providers = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(current_identity_providers)
    @is_in_b_group = is_in_b_group_rp_slides?
  end

  def choosing_a_company
    @is_in_b_group = is_in_b_group_rp_slides?
  end

  def identity_accounts
    @is_in_b_group = is_in_b_group_rp_slides?
  end

private

  def alternative_name_rp_slides
    ab_test_cookie = Cookies.parse_json(cookies[CookieNames::AB_TEST])['rp_slides']
    if AB_TESTS['rp_slides']
      AB_TESTS['rp_slides'].alternative_name(ab_test_cookie)
    else
      'default'
    end
  end

  def is_in_b_group_rp_slides?
    alternative_name_rp_slides == 'rp_slides_tailored'
  end
end
