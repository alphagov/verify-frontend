module UserErrors
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

  def something_went_wrong(exception, status = :internal_server_error)
    logger.error(exception)
    render_error('something_went_wrong', status)
  end

  def something_went_wrong_warn(exception)
    logger.warn(exception)
    render_error('something_went_wrong', :internal_server_error)
  end
end
