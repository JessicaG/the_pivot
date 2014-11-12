class VendorsController < ApplicationController

  def index
    @vendors = Vendor.all
  end

  # def show
  #   @categories = Category.all
  #   @vendor = Vendor.find_by(slug: params[:slug])
  # end

  def show
    @categories = Category.all
  	@vendor = Vendor.find_by!(slug: params[:slug])
  	if @vendor.display?
  		render :show
  	else
  		raise ActiveRecord::RecordNotFound
    end
  end

  def new
    @vendor = Vendor.new()
  end

  def create
    @vendor = Vendor.new(vendor_params)
    if @vendor.save
      redirect_to root_path
      flash[:notice] = "Your request for a new store has been sent! We'll let you know within 24 hours if your store is approved!"
    else
      render 'new'
    end
  end

  private

  def vendor_params
    params.require(:vendor).permit(:name, :description, :slug, :street, :city, :state, :zip)
  end
end
