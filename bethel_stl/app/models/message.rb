class Message < ApplicationRecord
  belongs_to :contact_group, optional: true
  has_many :message_deliveries, dependent: :destroy

  enum :channel, { sms: "sms", email: "email" }
  enum :status, { scheduled: "scheduled", sending: "sending", sent: "sent", captured: "captured", failed: "failed", cancelled: "cancelled" }

  # Group deletion preserves history, but every new message needs a group.
  validates :contact_group, presence: true, on: :create
  validates :body, presence: true
  validates :channel, presence: true
  validates :subject, presence: true, length: { maximum: 200 }, if: :email?
  validates :subject, format: { without: /[\r\n]/, message: "must be a single line" }, if: :email?

  scope :recent, -> { order(created_at: :desc) }

  def send_now?
    scheduled_at.nil? || scheduled_at <= Time.current
  end

  def recipient_label
    contact_group&.name || "No group"
  end
end
