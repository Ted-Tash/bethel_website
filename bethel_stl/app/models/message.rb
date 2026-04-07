class Message < ApplicationRecord
  belongs_to :contact_group, optional: true
  has_many :message_deliveries, dependent: :destroy

  enum :channel, { sms: "sms", email: "email" }
  enum :status, { scheduled: "scheduled", sending: "sending", sent: "sent", failed: "failed" }

  validates :body, presence: true

  scope :recent, -> { order(created_at: :desc) }

  def send_now?
    scheduled_at.nil? || scheduled_at <= Time.current
  end

  def recipient_label
    contact_group&.name || "Everyone"
  end
end
