class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  layout "admin"

  private

  def require_admin!
    head :forbidden unless authorized_for_admin?
  end

  def authorized_for_admin?
    current_user.super_admin?
  end
end
