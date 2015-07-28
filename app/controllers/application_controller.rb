class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :log_user_activity

  rescue_from CanCan::AccessDenied do |exception|
    if user_session
      redirect_url_ = '/'
    else
      redirect_url_ = user_session_url
    end
    redirect_to redirect_url_, :alert => exception.message
  end

  private

  def log_user_activity
    current_user.touch if current_user
  end
end
