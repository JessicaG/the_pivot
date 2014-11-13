class Order < ActiveRecord::Base
  include US
  include ItemQuantity

  belongs_to :user
  has_many :line_items
  has_many :items, through: :line_items

  validates :items, presence: true, on: :create
  validates :user, presence: true
  validates :status, inclusion: { in: :statuses }
  validates :exchange, inclusion: { in: :exchanges }
  validates :street_number,
            :street,
            :city,
            presence: true, if: :delivery?
  validates :state, inclusion: states, if: :delivery?
  validates :zip, format: { with: /\d{5}\d*/ }, if: :delivery?
  validates :latitude, presence:true, if: :delivery?
  validates :longitude, presence:true, if: :delivery?
  
  def delivery?
    exchange == 'delivery'
  end

  def statuses
    ['ordered', 'completed', 'cancelled', 'paid']
  end

  def exchanges
    ['pickup', 'delivery']
  end

  def add_item(item_id)
    self.items << Item.find(item_id)
  end

  def update_quantity(item_id, quantity)
    self.items.delete(item_id)
    quantity.to_i.times { add_item(item_id) }
  end

  def populate(cart, current_user)
    cart.items_to_quantities.to_h.each do |item, quantity|
      quantity.times { self.items << item }
    end

	  self.user = current_user
  end

  def group_by_vendor
    self.items.group_by(&:vendor)
  end

  def vendor_order_items
    self.line_items.group_by(&:vendor)
  end

  def vendor_orders
    vendor_order_items.map do |key, value|
      VendorOrder.new(self, key, value)
    end
  end

  def convert_points
    self.latitude.to_f   
    self.longitude.to_f   
  end
 
  def text_customer(order)
    customer_phone_number = "3034789928" # in production, change to match @user.phone_number

    twilio_sid = ENV["TWILIO_SID"] 
    twilio_token = ENV["TWILIO_TOKEN"]
    twilio_phone_number = ENV["TWILIO_PHONE_NUMBER"]

    @twilio_client = Twilio::REST::Client.new(twilio_sid, twilio_token)

    @twilio_client.account.sms.messages.create(
      from: twilio_phone_number,
      to: customer_phone_number,
      body: "Airlift order #{order.id} confirmation. Help is on the way!"
    )
  end
end
