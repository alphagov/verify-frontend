require 'browser'

module DeviceType
  MOBILE = 'device_type_mobile'.freeze
  OTHER = 'device_type_other'.freeze

  def device_type
    browser.device.mobile? ? { MOBILE => true } : { OTHER => true }
  end
end
