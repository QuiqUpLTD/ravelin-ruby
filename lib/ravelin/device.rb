module Ravelin
  class Device < RavelinObject
    # EVENT_NAME = :device

    attr_accessor :device_id,
      :type,
      :manufacturer,
      :model,
      :os,
      :ip_address,
      :browser,
      :javascript_enabled,
      :cookies_enabled,
      :screen_resolution
  end
end
