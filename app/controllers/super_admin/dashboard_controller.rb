class SuperAdmin::DashboardController < SuperAdmin::BaseController

  def index
    @vendors = Vendor.approved
    @categories = Category.all
    @users = User.all
  end
end
