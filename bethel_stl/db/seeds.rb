# Create default admin user for development
if Rails.env.development?
  User.find_or_create_by!(email: 'admin@bethelstl.org') do |user|
    user.password = 'password123'
    user.admin = true
    puts 'Created admin user: admin@bethelstl.org / password123'
  end
end
