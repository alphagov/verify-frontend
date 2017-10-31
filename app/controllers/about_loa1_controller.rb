class AboutLoa1Controller < ApplicationController
  layout 'slides', except: [:choosing_a_company]

  def index
    @tailored_text = current_transaction.tailored_text
    render 'about/about'
  end

  def certified_companies
    render 'about/certified_companies_LOA1'
  end

  def identity_accounts
    render 'about/identity_accounts_LOA1'
  end

  def choosing_a_company
    render 'about/choosing_a_company'
  end
end
