class ConfigurableJourneyController < ApplicationController
  helper_method :next_page

  def next_page
    @journeys ||= Journeys.new do
      {
        about_path => about_certified_companies_path,
        about_certified_companies_path => about_identity_accounts_path,
        about_identity_accounts_path => about_choosing_a_company_path,
        about_choosing_a_company_path => will_it_work_for_me_path
      }
    end
    @journeys.get_path(request.path)
  end
end
