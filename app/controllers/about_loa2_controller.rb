class AboutLoa2Controller < ApplicationController
  layout 'slides', except: [:choosing_a_company]
  include AbTestHelper

  def index
    @tailored_text = current_transaction.tailored_text
    render 'about/about'
  end

  def certified_companies
    @identity_providers = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(current_identity_providers)
    render 'about/certified_companies_LOA2'
  end

  def identity_accounts
    render 'about/identity_accounts_LOA2'
  end

  def choosing_a_company
    render 'about/choosing_a_company'
  end
end
