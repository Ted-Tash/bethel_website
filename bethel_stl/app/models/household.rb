class Household < ApplicationRecord
  has_many :members, dependent: :destroy
  accepts_nested_attributes_for :members, allow_destroy: true, reject_if: :all_blank

  validates :name, presence: true

  def full_address
    [street, city, state, zip].select(&:present?).join(', ')
  end
end
