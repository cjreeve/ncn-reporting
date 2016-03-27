class Users::RegistrationsController < Devise::RegistrationsController
  before_filter :configure_sign_up_params, only: [:create]
  before_filter :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
    def new
      super
    end

  # POST /resource
  # def create
  #   super
  # end

  # GET /resource/edit
    def edit
      super
    end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

    protected

    def allowed_user_paramn
      new_user_params = [:name, :receive_email_notifications, :administrative_area_tokens, route_ids: [], group_ids: [], label_ids: []]
      if current_user.is_admin? && !current_user.is_locked?
        return new_user_params + [:role, :is_admin, :is_locked]
      else
        return new_user_params
      end
    end

  # If you have extra params to permit, append them to the sanitizer.
    def configure_sign_up_params
      devise_parameter_sanitizer.for(:sign_up) << allowed_user_paramn
    end

  # If you have extra params to permit, append them to the sanitizer.
    def configure_account_update_params
      devise_parameter_sanitizer.for(:account_update) << allowed_user_paramn
    end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
