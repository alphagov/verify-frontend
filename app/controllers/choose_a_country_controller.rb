class ChooseACountryController < ApplicationController
  def choose_a_country
  end

  def choose_a_country_submit
    country = params[:country]
    if country.empty?
      flash.now[:errors] = true
      render 'choose_a_country'
      return
    end

    redirect_to '/redirect-to-country'
  end

  def redirect_to_country
    'TODO: The country page HERE'
  end
end
