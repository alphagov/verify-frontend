class ConfigurableJourneyController < ApplicationController
  helper_method :next_page

  def next_page(conditions = [])
    @journeys ||= Journeys.new do
      branch_at start_path,
        [:registration] => about_path,
        [:sign_in] => sign_in_path

      at about_path, next: about_certified_companies_path
      at about_certified_companies_path, next: about_identity_accounts_path
      at about_identity_accounts_path, next: about_choosing_a_company_path
      at about_choosing_a_company_path, next: will_it_work_for_me_path

      branch_at will_it_work_for_me_submit_path,
        [] => why_might_this_not_work_for_me_path,
        [:uk_address_but_not_resident] => may_not_work_if_you_live_overseas_path,
        [:no_uk_address] => will_not_work_without_uk_address_path,
        [:above_age_threshold_and_resident] => select_documents_path
    end
    @journeys.get_path(request.path, conditions)
  end
end
