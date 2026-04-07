class ContactGroup < ApplicationRecord
  has_many :contact_group_memberships, dependent: :destroy
  has_many :members, through: :contact_group_memberships
  has_many :messages, dependent: :nullify

  validates :name, presence: true
end
