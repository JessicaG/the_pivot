class VendorAdmin::UsersController < VendorAdmin::BaseController
  before_action :set_user, except: [:index, :new, :create]

  def index
    @users = User.where(vendor_id: current_user.vendor_id.to_s)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to vendor_admin_users_path
      flash[:notice] = "You successfully created #{@user.role} #{@user.full_name}!"
    else
      render :new
    end
  end

  def show
  end

  def update
    if @user.update(user_params)
      flash[:notice] = "Your account information has been successfully updated!"
      redirect_to vendor_admin_path
    else
      redirect_to :back
      flash[:notice] = "Error saving your new information."
    end
  end

  def destroy
    @user.destroy
    redirect_to vendor_admin_path
  end

  def edit
    render 'edit_user_role'
  end

  private

    def user_params
      params.require(:user).permit(:first_name, :last_name, :nickname, :email, :password, :role)
    end

    def set_user
      @user = User.find(params[:id])
    end

end
