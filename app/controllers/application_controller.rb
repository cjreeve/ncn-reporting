class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  before_filter :log_user_activity
  before_filter :load_global_variables

  protect_from_forgery# with: :exception

  after_filter :store_location

  def store_location
    # store last url - this is needed for post-login redirect to whatever the user last visited.
    return unless request.get? 
    if (request.path != "/users/sign_in" &&
        request.path != "/users/sign_up" &&
        request.path != "/users/password/new" &&
        request.path != "/users/password/edit" &&
        request.path != "/users/confirmation" &&
        request.path != "/users/sign_out" &&
        !request.xhr?) # don't store ajax calls
      session[:previous_url] = request.fullpath 
    end
  end

  def after_sign_in_path_for(resource)
    session[:previous_url] || root_path
  end

  rescue_from CanCan::AccessDenied do |exception|
    account_locked = nil

    if user_session
      if current_user.is_locked?
        sign_out current_user
        account_locked = "this account has been locked"
      end
      redirect_url_ = '/'
    else
      store_location()
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

  def load_global_variables
    @current_region = current_user.try(:region)
  end
end
