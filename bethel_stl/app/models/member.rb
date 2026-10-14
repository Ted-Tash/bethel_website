class Member < ApplicationRecord
  belongs_to :household
  has_many :contact_group_memberships, dependent: :destroy
  has_many :contact_groups, through: :contact_group_memberships
  has_many :message_deliveries, dependent: :nullify

  before_validation :reset_consent_for_changed_email, on: :update

  validates :first_name, presence: true
  validates :last_name, presence: true

  scope :with_phone, -> { where.not(phone: [ nil, "" ]) }
  scope :with_email, -> { where.not(email: [ nil, "" ]).where(email_consent: true) }

  def normalized_email
    email.to_s.strip.downcase
  end

  def email_suppressed?
    EmailSuppression.exists?(email: normalized_email)
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def reset_consent_for_changed_email
    if will_save_change_to_email? && email_in_database.to_s.strip.downcase != normalized_email
      self.email_consent = false
    end
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
