class ChooseACountryController < ApplicationController
  before_action :validate_session
  before_action :ensure_session_eidas_supported

  def choose_a_country
    setup_countries
  end

  def choose_a_country_submit
    session_id = setup_countries

    country = params[:country]
    if country.empty?
      flash.now[:errors] = true
      render 'choose_a_country'
      return
    end

    SESSION_PROXY.set_selected_country(session_id, country)

    redirect_to '/redirect-to-country'
  end

private

  def setup_countries
    session_id = session['verify_session_id']
    response = SESSION_PROXY.get_countries(session_id)
    countries_map = response.map { |country| Country.from_api(country) }
    @countries = COUNTRY_DISPLAY_DECORATOR.decorate_collection(countries_map)
    session_id
  end
end
