class UsersController < ApplicationController
  before_action :signed_in_user, only: [:index, :edit, :update, :show, :destroy]
  before_filter :correct_user, only: [:edit, :update]
  before_filter :admin_user, only: :destroy

  def new
    redirect_to(root_path) unless !signed_in?
    @user = User.new
  end

  def create
    redirect_to(root_path) unless !signed_in?
    @user = User.new(user_params)
    if @user.save
      # Handle a successful save
      sign_in(@user, 0)
      @user.send_user_confirm
      flash[:success] = "Welcome to Football Pool Mania!"
      redirect_to @user
    else
      @user.password = ""
      @user.password_confirmation = ""
      render 'new'
    end
  end

  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      sign_in(@user, 0)
      redirect_to @user
    else
      render 'edit'
    end
  end
  
  def confirm
    @user = User.find_by_confirmation_token!(params[:confirmation_token])
    if @user
      @user.update_attribute(:confirmed, true)
      redirect_to root_url, notice: "User account has been confirmed!"
    else
      render :edit
    end
  end

  def resend_confirm
      if current_user.confirmed?
        redirect_to root_url, notice: "User account has already been confirmed!"
      else
        current_user.send_user_confirm
      redirect_to root_url, notice: "Confirm message has been resent!"
      end
  end

  def destroy
    @user = User.find(params[:id])
    if current_user?(@user)
      flash[:notice] = "You cannot delete yourself!"
    else
      #
      # First we need to delete the pools owned by this user and associated
      # pool memberships
      #
      @user.pools.each do |pool|
        pool.remove_memberships
        pool.recurse_delete
      end
      @user.destroy
      flash[:success] = "User deleted."
    end
    redirect_to users_url
  end
  
  def admin_add
    if current_user.admin? 
      user = User.find(params[:id])
      user.update_attribute(:admin, '1')
      flash[:success] = "Admin status has been granted to User: '#{user.name}!"
    else
      flash[:error] = "Only an Admin user can update admin status!"
    end
    redirect_to users_url
  end
  
  def admin_del
    if current_user.admin? 
      user = User.find(params[:id])
      user.update_attribute(:admin, '0')
      flash[:success] = "Admin status has been removed from User: '#{user.name}!"
    else
      flash[:error] = "Only an Admin user can update admin status!"
    end
    redirect_to users_url
  end

  private

    def user_params
      params.require(:user).permit(:name, :user_name, :email, :password,
                                   :password_confirmation)
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
