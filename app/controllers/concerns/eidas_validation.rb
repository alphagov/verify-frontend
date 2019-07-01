module EidasValidation
  extend ActiveSupport::Concern

  def ensure_session_eidas_supported
    txn_supports_eidas = session[:transaction_supports_eidas]
    unless txn_supports_eidas
      something_went_wrong('Transaction does not support Eidas', :forbidden)
    end
  end
end
