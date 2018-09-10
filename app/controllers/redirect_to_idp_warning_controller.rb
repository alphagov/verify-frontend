require 'partials/idp_selection_partial_controller'

class RedirectToIdpWarningController < ApplicationController
  include IdpSelectionPartialController

  SELECTED_IDP_HISTORY_LENGTH = 5
  helper_method :user_has_no_docs_or_foreign_id_only?, :other_ways_description

  def index
    @idp = decorated_idp
    @service_name = current_transaction.name
    if @idp.viewable?
      render 'redirect_to_idp_warning'
    else
      something_went_wrong("Couldn't display IDP with entity id: #{@idp.entity_id}")
    end
  end

  def continue
    idp = decorated_idp
    if idp.viewable?
      select_registration(idp)
      redirect_to redirect_to_idp_register_path
    else
      something_went_wrong("Couldn't display IDP with entity id: #{idp.entity_id}")
    end
  end

  def continue_ajax
    idp = decorated_idp
    if idp.viewable?
      select_registration(idp)
      ajax_idp_redirection_registration_request(recommended, idp.entity_id)
    else
      render status: :bad_request
    end
  end

private

  def select_registration(idp)
    POLICY_PROXY.select_idp(session['verify_session_id'], idp.entity_id, session['requested_loa'], true)
    set_journey_hint_followed(idp.entity_id)
    set_attempt_journey_hint(idp.entity_id)
    register_idp_selections(idp.display_name)
  end

  def register_idp_selections(idp_name)
    session[:selected_idp_name] = idp_name
    selected_idp_names = session[:selected_idp_names] || []
    if selected_idp_names.size < SELECTED_IDP_HISTORY_LENGTH
      selected_idp_names << idp_name
      session[:selected_idp_names] = selected_idp_names
    end
  end

  def recommended
    begin
      if session.fetch(:selected_idp_was_recommended)
        '(recommended)'
      else
        '(not recommended)'
      end
    rescue KeyError
      '(idp recommendation key not set)'
    end
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
    selected_answer_store.selected_evidence_for('documents').empty?
  end

  def user_has_foreign_doc_only?
    selected_answer_store.selected_evidence_for('documents') == [:non_uk_id_document]
  end
end
