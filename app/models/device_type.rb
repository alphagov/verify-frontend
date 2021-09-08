require "browser"

module DeviceType
  MOBILE = :device_type_mobile
  OTHER = :device_type_other

  def device_type
    browser.device.mobile? ? { MOBILE => true } : { OTHER => true }
  end
end
