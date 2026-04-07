class Member < ApplicationRecord
  belongs_to :household
  has_many :contact_group_memberships, dependent: :destroy
  has_many :contact_groups, through: :contact_group_memberships
  has_many :message_deliveries, dependent: :nullify

  validates :first_name, presence: true
  validates :last_name, presence: true

  scope :with_phone, -> { where.not(phone: [nil, ""]) }

  def full_name
    "#{first_name} #{last_name}"
  end

  def normalized_phone
    return nil if phone.blank?

    digits = phone.gsub(/\D/, "")
    if digits.length == 10
      "+1#{digits}"
    elsif digits.length == 11 && digits.start_with?("1")
      "+#{digits}"
    else
      "+#{digits}"
    end
  end
end
