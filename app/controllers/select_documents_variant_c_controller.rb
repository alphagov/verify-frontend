require 'partials/viewable_idp_partial_controller'
require 'partials/variant_partial_controller'

class SelectDocumentsVariantCController < ApplicationController
  include ViewableIdpPartialController
  include VariantPartialController

  def index
    @form = SelectDocumentsVariantCForm.from_session_storage(selected_answer_store.selected_answers.fetch('documents', {}))
    render :index
  end

  def select_documents
    @form = SelectDocumentsVariantCForm.from_post(params['select_documents_variant_c_form'] || {})
    if @form.valid?
      selected_answer_store.store_selected_answers('documents', @form.to_session_storage)
      idps_available = IDP_RECOMMENDATION_ENGINE_variant_c.any?(current_identity_providers_for_loa_by_variant('c'), selected_evidence, current_transaction_simple_id)
      redirect_to idps_available ? choose_a_certified_company_path : select_documents_advice_path
    else
      flash.now[:errors] = @form.errors.full_messages.join(', ')
      render :index
    end
  end

  def advice
    suggestions = IDP_RECOMMENDATION_ENGINE_variant_c.get_suggested_idps(current_identity_providers_for_loa_by_variant('c'), selected_evidence, current_transaction_simple_id)

    @evidence = selected_evidence
    @advice_codes = segment_advice(suggestions[:user_segments])
    @other_ways_description = current_transaction.other_ways_description
    @other_ways_text = current_transaction.other_ways_text

    render :advice
  end
end
