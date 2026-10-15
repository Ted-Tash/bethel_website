class MessageDelivery < ApplicationRecord
  belongs_to :message
  belongs_to :member, optional: true

  enum :status, { pending: "pending", sent: "sent", captured: "captured", skipped: "skipped", failed: "failed" }
end
