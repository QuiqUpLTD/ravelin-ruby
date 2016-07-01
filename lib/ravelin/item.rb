module Ravelin
  class Item < RavelinObject
    # EVENT_NAME = :item

    attr_accessor :sku,
      :name,
      :price,
      :currency,
      :brand,
      :upc,
      :category,
      :quantity,
      :custom

    attr_required :sku, :quantity
  end
end
