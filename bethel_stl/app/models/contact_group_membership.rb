class ContactGroupMembership < ApplicationRecord
  belongs_to :contact_group
  belongs_to :member

  validates :member_id, uniqueness: { scope: :contact_group_id }
end
