class FeedbackSentController < ApplicationController
  skip_before_action :validate_session

  ERROR_PAGES = %w(ERROR_PAGE EXPIRED_ERROR_PAGE COOKIE_NOT_FOUND_PAGE).freeze

  def index
    flash.keep('email_provided')
    flash.keep('feedback_referer')
    flash.keep('feedback_source')
    @link_back_to_verify = choose_link_back_to_verify(flash['feedback_referer'], flash['feedback_source'])
    @email_provided = flash['email_provided']
    @session_valid = session_validator.validate(cookies, session).ok?
    render
  end

  def choose_link_back_to_verify(feedback_referer, feedback_source)
    if feedback_source.nil? || ERROR_PAGES.include?(feedback_source)
      start_path
    else
      feedback_referer
    end
  end
end
