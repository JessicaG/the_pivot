class VendorAdmin::VendorsController < VendorAdmin::BaseController
before_action :set_vendor, except: [:index, :new, :create]

  def edit
    @vendor
  end

  # def show
  # end

  def update
    if @vendor.update(vendor_params)
      flash[:notice] = "Your account information has been successfully updated!"
      redirect_to vendor_admin_path
    else
      redirect_to edit_vendor_admin_vendor_path(@vendor)
      flash[:notice] = "Error saving your new information."
    end
  end

  private

    def vendor_params
      params.require(:vendor).permit(:name, :slug, :description)
    end

    def set_vendor
      @vendor = Vendor.find(params[:id])
    end

end
