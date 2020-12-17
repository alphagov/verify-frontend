module EidasValidationPartialController
  def ensure_session_eidas_supported
    txn_supports_eidas = session[:transaction_supports_eidas]
    unless txn_supports_eidas && before_eidas_shutdown?
      something_went_wrong_warn("Transaction does not support Eidas", :forbidden)
    end
  end

private

  def before_eidas_shutdown?
    CONFIG.eidas_disabled_after.nil? || DateTime.now < CONFIG.eidas_disabled_after
  end
end
