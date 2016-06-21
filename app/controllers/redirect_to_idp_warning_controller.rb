class RedirectToIdpWarningController < ApplicationController
  SELECTED_IDP_HISTORY_LENGTH = 5
  helper_method :user_has_no_docs_or_foreign_id_only?, :other_ways_description

  def index
    @idp = decorated_idp
    if @idp.viewable?
      @recommended = recommended?
      render 'index'
    else
      something_went_wrong("Couldn't display IDP with entity id: #{@idp.entity_id}")
    end
  end

  def continue
    idp = decorated_idp
    if idp.viewable?
      select_registration(idp)
      redirect_to redirect_to_idp_path
    else
      something_went_wrong("Couldn't display IDP with entity id: #{idp.entity_id}")
    end
  end

  def continue_ajax
    idp = decorated_idp
    if idp.viewable?
      select_registration(idp)
      authn_request_json = SESSION_PROXY.idp_authn_request(cookies)
      render json: authn_request_json
    else
      render status: :bad_request
    end
  end

private

  def select_registration(idp)
    SESSION_PROXY.select_idp(cookies, idp.entity_id, true)
    set_journey_hint(idp.entity_id, I18n.locale)
    register_idp_selections(idp.display_name)
  end

  def register_idp_selections(idp_name)
    selected_idp_names = session[:selected_idp_names] || []
    if selected_idp_names.size < SELECTED_IDP_HISTORY_LENGTH
      selected_idp_names << idp_name
      session[:selected_idp_names] = selected_idp_names
    end
    FEDERATION_REPORTER.report_idp_registration(request, idp_name, selected_idp_names, selected_evidence_values, recommended?)
  end

  def recommended?
    session.fetch(:selected_idp_was_recommended)
  end

  def decorated_idp
    @decorated_idp ||= IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(selected_identity_provider)
  end

  def other_ways_description
    @other_ways_description = current_transaction.other_ways_description
  end

  def user_has_no_docs_or_foreign_id_only?
    user_has_no_docs? || user_has_foreign_doc_only?
  end

  def user_has_no_docs?
    (stored_selected_evidence['documents'] || []).empty?
  end

  def user_has_foreign_doc_only?
    stored_selected_evidence['documents'] == ['non_uk_id_document']
  end
end
