class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  enum :role, { super_admin: "super_admin", conference_manager: "conference_manager" }, validate: true

  def can_manage_conferences?
    super_admin? || conference_manager?
  end
end
