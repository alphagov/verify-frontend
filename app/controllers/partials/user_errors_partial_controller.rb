module UserErrorsPartialController
  def render_error(partial, status)
    case partial
    when :session_timeout
      session_timeout(nil, status)
    when :no_cookies
      render_partial("no_cookies", status)
    when :session_error
      session_error(nil)
    when :something_went_wrong
      something_went_wrong(nil, status)
    else
      raise ArgumentError "Unknown error type specified: '#{partial}'"
    end
  end

  def render_not_found
    set_locale
    respond_to do |format|
      format.html { render "errors/404", status: 404 }
      format.json { render json: {}, status: 404 }
    end
  end

  def session_timeout(exception = nil, status = :forbidden)
    @other_ways_description = current_transaction.other_ways_description
    @redirect_to_destination = session[:transaction_homepage]

    logger.info(exception) if exception
    render_partial("session_timeout", status)
  end

  def session_error(exception = nil)
    logger.warn(exception) if exception
    render_partial("session_error", :bad_request)
  end

  def something_went_wrong(exception = nil, status = :internal_server_error)
    if exception
      logger.error(exception)
      logger.info("Something went wrong: #{exception.try(:message) || exception}")
    end

    check_whether_recoverable
    render_partial("something_went_wrong", status)
  end

  def something_went_wrong_warn(exception, status = :internal_server_error)
    logger.warn(exception)
    logger.info("Something went wrong: #{exception.try(:message) || exception}")
    check_whether_recoverable
    render_partial("something_went_wrong", status)
  end

  def upstream_error(exception)
    something_went_wrong_warn(exception)
  end

  def raise_unknown_format
    logger.warn("Received a request with unexpected accept headers - #{request.headers['ACCEPT']}")
    render plain: "Unable to serve the requested format", status: 406
  end

private

  def render_partial(partial, status)
    set_locale
    respond_to do |format|
      format.html { render "errors/#{partial}", status: status, layout: "application" }
      format.json { render json: {}, status: status }
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
end
