class Admin::ConferenceBaseController < Admin::BaseController
  private

  def authorized_for_admin?
    current_user.can_manage_conferences?
  end
end
