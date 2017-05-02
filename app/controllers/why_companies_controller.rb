class WhyCompaniesController < ApplicationController
  def index
    if is_loa1?
      render :why_companies_LOA1
    else
      render :why_companies_LOA2
    end
  end
end
