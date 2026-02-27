class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  layout 'admin'

  private

  def require_admin!
    unless current_user.admin?
      sign_out current_user
      redirect_to new_user_session_path, alert: 'Access denied.'
    end
  end
end
