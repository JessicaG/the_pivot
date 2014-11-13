class OrdersController < ApplicationController
	load_and_authorize_resource
  helper_method :find_vendor_name

	def new
		@order = Order.new
    @vendors = Vendor.all
    @locations = @vendors.map do |vendor|
      { name: vendor.name, 
        latitude: vendor.latitude, 
        longitude: vendor.longitude }
    end
	end

	def index
	end

	def create
    order = Order.new(order_params)
    order.populate(cart, current_user)
    order.convert_points
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
      flash.now[:notice] = order.errors.full_messages.to_sentence 
			redirect_to :back
		end
	end

	def show
		@order = Order.includes(:items).find(params[:id])
    @vendors = @order.group_by_vendor
	end

  def exchange
  end

  def store_lat_long
    session[:latitude] = params[:latitude]
    session[:longitude] = params[:longitude]
  end
  
	private

	def order_params
		params.require(:order).permit(:street_number, :street, :city, :state, :zip, :exchange, :status, :latitude, :longitude, :pickup_location, :pickup_date)
	end

  def find_vendor_name(vendor_id)
    Vendor.where(id: vendor_id).first.name
  end

 end

