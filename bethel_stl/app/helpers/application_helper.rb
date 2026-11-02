module ApplicationHelper
  def admin_home_path
    current_user.super_admin? ? admin_dashboard_path : admin_conferences_path
  end

  def active_nav_class(path)
    current_page?(path) ? 'menu-active' : ''
  end
end
