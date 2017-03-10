class ConfigurableJourneyController < ApplicationController
  helper_method :next_page

  def next_page
    @journeys ||= Journeys.new do
      at about_path, next: about_certified_companies_path
      at about_certified_companies_path, next: about_identity_accounts_path
      at about_identity_accounts_path, next: about_choosing_a_company_path
      at about_choosing_a_company_path, next: will_it_work_for_me_path
    end
    @journeys.get_path(request.path)
  end
end
