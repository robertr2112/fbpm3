class ApplicationController < ActionController::Base
  
  protect_from_forgery
  include SessionsHelper
  
  def redirect_to_back_or_default(default = root_url)
    redirect_back(fallback_location: default)
  end
  
end
