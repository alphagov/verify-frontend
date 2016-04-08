require 'select_documents_form_mapper'

class SelectDocumentsController < ApplicationController
  def index
    @form = SelectDocumentsForm.new({})
  end

  def select_documents
    ANALYTICS_REPORTER.report(request, 'Select Documents Next')
    @form = SelectDocumentsForm.new(SelectDocumentsFormMapper.map(params))
    if @form.valid?
      selected_evidence = @form.selected_evidence
      if IDP_ELIGIBILITY_CHECKER.any_for_documents?(selected_evidence, available_idps)
        redirect_to uri_with_evidence_query(select_phone_path, selected_evidence)
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

  def uri_with_evidence_query(path, selected_evidence)
    selected_evidence = [:no_documents] if selected_evidence.empty?
    s = '?' + selected_evidence.collect { |evidence| "selected-evidence=#{evidence}" }.join('&')
    URI(path + s).to_s
  end
end
