module ApplicationHelper
  def active_nav_class(path)
    current_page?(path) ? 'menu-active' : ''
  end
end
