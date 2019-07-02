module UserErrorsPartialController
  def render_error(partial, status, locals = {})
    set_locale
    respond_to do |format|
      format.html { render "errors/#{partial}", status: status, layout: 'application', locals: locals }
      format.json { render json: {}, status: status }
    end
  end

  def render_not_found
    set_locale
    respond_to do |format|
      format.html { render 'errors/404', status: 404 }
      format.json { render json: {}, status: 404 }
    end
  end

  def session_timeout(exception)
    logger.info(exception)
    render_error('session_timeout', :forbidden)
  end

  def session_error(exception)
    logger.warn(exception)
    render_error('session_error', :bad_request)
  end

  def upstream_error(exception)
    if handle_eidas_scheme_unavailable?(exception)
      eidas_scheme_unavailable_error(exception)
    else
      something_went_wrong_warn(exception)
    end
  end

  def render_something_went_wrong(status)
    locals = {}

    begin
      if session
        logger.info("Recovering session for: #{session[:verify_simple_id]}")
        locals[:transaction_homepage] = session[:transaction_homepage]

        if current_transaction
          logger.info("Recovered other ways to: #{current_transaction.other_ways_description}")
          locals[:other_ways_description] = current_transaction.other_ways_description
          locals[:other_ways_text] = current_transaction.other_ways_text
        end
      end
    rescue StandardError => e
      # Rendering the error page must never fail (to avoid infinite loops), so
      # catch and swallow any errors raised.
      logger.info("Failed to recover: #{e.message}")
    end

    render_error('something_went_wrong', status, locals)
  end

  def something_went_wrong(exception, status = :internal_server_error)
    logger.error(exception)
    render_something_went_wrong(status)
  end

  def something_went_wrong_warn(exception, status = :internal_server_error)
    logger.warn(exception)
    render_something_went_wrong(status)
  end

  def eidas_scheme_unavailable_error(exception)
    @selected_country = COUNTRY_DISPLAY_DECORATOR.decorate(selected_country)
    @other_ways_text = current_transaction.other_ways_text

    logger.warn(exception)
    render_error('eidas_scheme_unavailable', :internal_server_error)
  end

private

  def handle_eidas_scheme_unavailable?(exception)
    identity_provider_selected? &&
      user_journey_type?(JourneyType::EIDAS) &&
      Api::EidasSchemeUnavailableError::TYPES.include?(exception.hub_type)
  end
end
