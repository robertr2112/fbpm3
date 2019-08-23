class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by_email(params[:email].downcase)
    if user && user.authenticate(params[:password])
      # Sign the user in and redirect to the page requested.
      sign_in(user, params[:remember_me])
      redirect_back_or user
    else
      # Error message for invalid user email ID
      flash.now[:error] = "Invalid email/password combination."
      render 'new'
    end
  end

  def destroy
    sign_out
    redirect_to root_url
  end
end
