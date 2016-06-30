class AboutController < ApplicationController
  layout 'slides', except: [:choosing_a_company]

  def index
    FEDERATION_REPORTER.report_registration(
      current_transaction_simple_id,
      request
    )
  end

  def certified_companies
    @identity_providers = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(current_identity_providers)
  end

  def choosing_a_company
    @next_path = show_age_question_first? ? will_it_work_for_me_path : select_documents_path
  end
end
