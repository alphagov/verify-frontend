class AboutController < ApplicationController
  layout 'slides', except: [:choosing_a_company]
  include AbTestHelper

  def index
    FEDERATION_REPORTER.report_registration(
      current_transaction,
      request
    )
    @tailored_text = current_transaction.tailored_text
  end

  def certified_companies
    @identity_providers = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(current_identity_providers)
  end

  def choosing_a_company
    AbTest.report('right_company', ab_test('right_company'), current_transaction_simple_id, request)
    @is_in_b_group = is_in_b_group?
  end

private

  def is_in_b_group?
    ab_test('right_company') == 'right_company_more_info'
  end
end
