class VendorsController < ApplicationController

  def index
    @vendors = Vendor.all
  end

  def show
    @categories = Category.all
    @vendor = Vendor.find_by(slug: params[:slug])
  end

  def new
    @vendor = Vendor.new()
  end

  def create
    @vendor = Vendor.new(vendor_params)
    if @vendor.save
      redirect_to root_path
      flash[:notice] = "Your store has been successfully created! You'll receive an email from Airlift soon."
    else
      render 'new'
    end
  end

  private

  def vendor_params
    params.require(:vendor).permit(:name, :description, :slug)
  end
end
