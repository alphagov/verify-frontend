class ChooseACountryController < ApplicationController
  before_action :validate_session
  before_action :ensure_session_eidas_supported

  def choose_a_country
    setup_countries
  end

  def choose_a_country_submit
    setup_countries

    country = params[:country]
    if country.empty?
      flash.now[:errors] = true
      render 'choose_a_country'
      return
    end

    # Call into Policy to change state
    # POST /api/countries (NL)
    API_CLIENT.post("/countries/#{session['verify_session_id']}/#{country}",
    '', {}, 200)

    redirect_to '/redirect-to-country'
  end

private

  def setup_countries
    session_id = session['verify_session_id']
    response = SESSION_PROXY.get_countries(session_id)
    countries_map = response.map { |country| Country.from_api(country) }
    @countries = COUNTRY_DISPLAY_DECORATOR.decorate_collection(countries_map)
  end
end
