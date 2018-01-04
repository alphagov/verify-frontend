require 'partials/viewable_idp_partial_controller'

class SelectPhoneController < ApplicationController
  include ViewableIdpPartialController

  def index
    @form = SelectPhoneForm.new({})
  end

  def select_phone
    @form = SelectPhoneForm.new(params['select_phone_form'] || {})
    if @form.valid?
      report_to_analytics('Phone Next')
      selected_answer_store.store_selected_answers('phone', @form.selected_answers)
      idps_available = IDP_RECOMMENDATION_ENGINE.any?(current_identity_providers_for_loa, selected_evidence, current_transaction_simple_id)
      redirect_to idps_available ? choose_a_certified_company_path : no_mobile_phone_path
    else
      flash.now[:errors] = @form.errors.full_messages.join(', ')
      render :index
    end
  end

  def no_mobile_phone
    @other_ways_description = current_transaction.other_ways_description
    @other_ways_text = current_transaction.other_ways_text
  end
end
