class Household < ApplicationRecord
  has_many :members, dependent: :destroy
  accepts_nested_attributes_for :members, allow_destroy: true

  validates :name, presence: true
  validate :max_two_members

  def full_address
    [street, city, state, zip].select(&:present?).join(', ')
  end

  private

  def max_two_members
    if members.reject(&:marked_for_destruction?).size > 2
      errors.add(:base, 'A household can have at most 2 members')
    end
  end
end
