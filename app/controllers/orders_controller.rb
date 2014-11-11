class OrdersController < ApplicationController
	load_and_authorize_resource
#  before_create :convert_points
  helper_method :find_vendor_name

	def new
		@order = Order.new
	end

	def index
	end

	def create
    order = Order.new(order_params)
    order.populate(cart, current_user)
    order.convert_points
#    require 'pry'; binding.pry
    cart.clear

		if order.save
      order.text_customer(order)
      vendor_orders = order.vendor_orders
      vendor_orders.each do |vendor_order|
        VendorNotifier.new_order_notification(current_user, order, vendor_order).deliver
      end
      flash[:notice] = "Your order has been successfully created!"
			redirect_to order
		else
			flash[:notice] = "Error placing order"
			redirect_to :back
		end
	end

	def show
		@order = Order.includes(:items).find(params[:id])
    @vendors = @order.group_by_vendor
	end

  def exchange
#    require 'pry'; binding.pry
  end

  def store_lat_long
    session[:latitude] = params[:latitude]
    session[:longitude] = params[:longitude]
    render text: ''
  end
  
	private

	def order_params
		params.require(:order).permit(:street_number, :street, :city, :state, :zip, :exchange, :status, :latitude, :longitude)
	end

 def find_vendor_name(vendor_id)
   Vendor.where(id: vendor_id).first.name
 end

 end

