require 'rails_helper'
require 'spec_helper'
require 'feedback_sent_controller'

describe FeedbackSentController do
  let(:non_error_source) { 'non_error_source' }
  let(:error_source) { 'ERROR_PAGE' }
  let(:referer) { 'referer' }

  it 'should return the referer if the feedback source is not an error ' do
    link = subject.choose_link_back_to_verify(referer, non_error_source)
    expect(link).to eql(referer)
  end

  %w(ERROR_PAGE EXPIRED_ERROR_PAGE COOKIE_NOT_FOUND_PAGE).each do |error_feedback_source|
    it "should return the start page if the feedback source is #{error_feedback_source}" do
      link = subject.choose_link_back_to_verify(referer, error_feedback_source)
      expect(link).to eql(start_path)
    end
  end

  it 'should return the start page if the feedback source is nil' do
    link = subject.choose_link_back_to_verify(referer, nil)
    expect(link).to eql(start_path)
  end
end
