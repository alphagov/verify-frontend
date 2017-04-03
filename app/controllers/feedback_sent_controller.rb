class FeedbackSentController < ApplicationController
  skip_before_action :validate_session

  def index
    flash.keep('email_provided')
    flash.keep('feedback_source')
    @email_provided = flash['email_provided']
    @session_valid = session_validator.validate(cookies, session).ok?
    @from_product_page = flash['feedback_source'] == 'PRODUCT_PAGE'
    if @session_valid || @from_product_page
      @link_back = FEEDBACK_SOURCE_MAPPER.page_from_source(flash['feedback_source'], I18n.locale)
    end
    render
  end
end
