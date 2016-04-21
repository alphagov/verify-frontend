require 'idp_eligibility/evidence_query_string_builder'

class SelectDocumentsController < ApplicationController
  def index
    @form = SelectDocumentsForm.new({})
  end

  def select_documents
    @form = SelectDocumentsForm.new(params['select_documents_form'] || {})
    if @form.valid?
      ANALYTICS_REPORTER.report(request, 'Select Documents Next')
      selected_evidence = @form.selected_evidence
      if documents_eligibility_checker.any?(selected_evidence, available_idps)
        uri = URI(select_phone_path)
        uri.query = IdpEligibility::EvidenceQueryStringBuilder.build(selected_evidence)
        redirect_to uri.to_s
      else
        redirect_to unlikely_to_verify_path
      end
    else
      flash.now[:errors] = @form.errors.full_messages.join(', ')
      render :index
    end
  end

private

  def available_idps
    SESSION_PROXY.federation_info_for_session(cookies).idps.collect { |idp| idp['simpleId'] }
  end

  def documents_eligibility_checker
    DOCUMENTS_ELIGIBILITY_CHECKER
  end
end
