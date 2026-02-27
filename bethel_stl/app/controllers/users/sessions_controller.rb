class Users::SessionsController < Devise::SessionsController
  layout 'devise'

  protected

  def after_sign_in_path_for(resource)
    admin_dashboard_path
  end

  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_path
  end
end
