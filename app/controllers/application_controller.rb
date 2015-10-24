class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :log_user_activity

  rescue_from CanCan::AccessDenied do |exception|
    account_locked = nil

    if user_session
      if current_user.role == 'locked'
        reset_session
        account_locked = "this account has been locked"
      end
      redirect_url_ = '/'
    else
      redirect_url_ = user_session_url
    end
    redirect_to redirect_url_, alert: (account_locked ? account_locked : exception.message)
  end

  def filter_params(params, new_params = {})
    the_params = params.permit(Rails.application.config.filter_params)
    the_params.merge!(new_params)
  end

  private

  def log_user_activity
    current_user.touch if current_user
  end
end
