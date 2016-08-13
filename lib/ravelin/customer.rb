module Ravelin
  class Customer < RavelinObject
    EVENT_NAME = :customer

    attr_accessor :customer_id,
      :registration_time,
      :name,
      :given_name,
      :family_name,
      :date_of_birth,
      :gender,
      :email,
      :email_verified_time,
      :username,
      :telephone,
      :telephone_verified_time,
      :telephone_country,
      :location,
      :country,
      :market,
      :custom

    attr_required :customer_id

    def location=(obj)
      @location = Ravelin::Location.new(obj)
    end
  end
end
