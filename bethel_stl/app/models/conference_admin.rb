class ConferenceAdmin < ApplicationRecord
  belongs_to :conference, inverse_of: :admins

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
end
