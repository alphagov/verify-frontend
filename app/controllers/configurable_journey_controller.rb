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
    end
    @journeys.get_path(request.path, conditions)
  end
end
