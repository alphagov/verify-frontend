module UserErrorsPartialController
  def render_error(partial, status)
    set_locale
    respond_to do |format|
      format.html { render "errors/#{partial}", status: status, layout: 'application' }
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

  # How often do we have the information needed to redirect the user back to the
  # service homepage?
  def check_whether_recoverable
    begin
      if session
        logger.info("Session may be recoverable; service: #{session[:verify_simple_id]}, homepage: #{session[:transaction_homepage]}")

        # Can we be clever and show the user other ways to access the service in
        # case Verify is persistently failing for them?
        if current_transaction
          logger.info("Have valid transaction: #{current_transaction.other_ways_description}")
        end
      else
        logger.info("Failed to recover: missing session")
      end
    rescue StandardError => e
      # We do not want to interfere with the normal error-handling behaviour, so
      # catch all errors.
      logger.info("Failed to recover: #{e.message}")
    end
  end

  def something_went_wrong(exception, status = :internal_server_error)
    logger.error(exception)
    check_whether_recoverable
    render_error('something_went_wrong', status)
  end

  def something_went_wrong_warn(exception, status = :internal_server_error)
    logger.warn(exception)
    check_whether_recoverable
    render_error('something_went_wrong', status)
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
