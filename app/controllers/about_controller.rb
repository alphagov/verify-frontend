class AboutController < ApplicationController
  layout 'slides', except: [:choosing_a_company]
  include AbTestHelper

  def index
    @tailored_text = current_transaction.tailored_text
    render :about
  end

  def certified_companies
    @identity_providers = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(current_identity_providers)
    render :certified_companies
  end

  def identity_accounts
    render :identity_accounts
  end

  def choosing_a_company
    render :choosing_a_company
  end
end
