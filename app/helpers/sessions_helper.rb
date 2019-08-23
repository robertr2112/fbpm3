module SessionsHelper
  # Handle all of the Sign in functions
  def sign_in(user, remember_me)
    remember_token = User.new_remember_token
    #  Use of cookies to save a session for longer than browser duration
    if remember_me
      cookies.permanent[:remember_token] = remember_token
    else
      cookies[:remember_token] = remember_token
    end
    user.update_attribute(:remember_token, User.encrypt(remember_token))
    self.current_user = user
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    #  Use of cookies to save a session for longer than browser duration
    remember_token = User.encrypt(cookies[:remember_token])
    @current_user ||= User.find_by(remember_token: remember_token)
  end

  def signed_in?
    !current_user.nil?
  end

  def sign_out
    self.current_user = nil
    #  Use of cookies to save a session for longer than browser duration
    cookies.delete(:remember_token)
  end

  def current_user?(user)
    user == current_user
  end

  def signed_in_user
    unless signed_in?
      store_location
      redirect_to signin_url, notice: "Please sign in."
    end
  end

  def confirmed_user
     redirect_to root_url unless current_user.confirmed?
  end

  def admin_user
     redirect_to root_url unless current_user.admin?
  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

  def store_location
    session[:return_to] = request.url
  end

  private

    #
    # These functions are used only when using cookies for session mgmt
    #
    def remember_token
      cookies.signed[:remember_token] || [nil, nil]
    end
end
