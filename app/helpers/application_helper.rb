module ApplicationHelper

  def print_price(price)
    number_to_currency price
  end

  def vendors
    @vendors ||= Vendor.all
  end

  def items
    @vendor_items = Item.all
  end

end
