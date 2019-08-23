class StaticPagesController < ApplicationController
  def home
    # if the user is signed_in then redirect to their home page
    if signed_in?
      redirect_to current_user
    end
  end

  def contact
  end

  def about
  end

  def help
  end

end
