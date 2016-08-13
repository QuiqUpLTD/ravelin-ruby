module Ravelin
  class Location < RavelinObject
    # EVENT_NAME = :location

    attr_accessor :location_id,
      :street1,
      :street2,
      :neighbourhood,
      :zone,
      :city,
      :region,
      :country,
      :po_box_number,
      :postal_code,
      :latitude,
      :longitude,
      :geohash,
      :custom
  end
end
