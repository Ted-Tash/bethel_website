class MessageDelivery < ApplicationRecord
  belongs_to :message
  belongs_to :member

  enum :status, { pending: "pending", sent: "sent", failed: "failed" }
end
