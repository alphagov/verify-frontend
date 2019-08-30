require 'uri'

class GoogleAnalytics
  attr_reader :tracker_id, :cross_domain_list

  def initialize(tracker_id, cross_domain_list = [])
    @enabled = tracker_id.present?
    @tracker_id = tracker_id
    @cross_domain_list = cross_domain_list
  end

  def enabled?
    @enabled
  end
end
