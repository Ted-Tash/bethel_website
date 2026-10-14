class EmailSuppression < ApplicationRecord
  validates :email, presence: true
  normalizes :email, with: ->(email) { email.strip.downcase }

  def self.token_for(email)
    Rails.application.message_verifier("email_unsubscribe").generate(email.strip.downcase, purpose: "email_unsubscribe")
  end

  def self.email_from_token(token)
    Rails.application.message_verifier("email_unsubscribe").verified(token, purpose: "email_unsubscribe")
  end

  def self.suppress!(email)
    create_or_find_by!(email: email.strip.downcase)
  end
end
