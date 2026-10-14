require "set"

class SendMessageJob < ApplicationJob
  queue_as :default
  # One bulk message at a time keeps memory and provider request rates bounded.
  limits_concurrency key: "mass-messages", to: 1, duration: 1.hour

  def perform(message_id)
    message = Message.find_by(id: message_id)
    return unless message

    # Claim atomically against cancellation and duplicate enqueues. Do not hold
    # a SQLite write transaction open during external network calls.
    claimed = Message.where(id: message.id, status: :scheduled).update_all(status: :sending, updated_at: Time.current)
    return unless claimed == 1
    message.reload

    members = message.contact_group ? message.contact_group.members : Member.all
    recipients = message.email? ? members.with_email : members.with_phone
    seen = Set.new

    recipients.find_each do |member|
      destination = message.email? ? member.normalized_email : member.normalized_phone
      next if message.email? && !seen.add?(destination)

      delivery = message.message_deliveries.create!(member: member, phone_or_email: destination)
      if message.email?
        result = ResendEmailService.send_email(delivery: delivery)
        status, error, provider_id = result.status, result.error, result.provider_id
      else
        result = TwilioSmsService.send_sms(to: destination, body: message.body)
        status, error, provider_id = result.success? ? :sent : :failed, result.error, result.sid
      end
      delivery.update!(status: status, error_message: error, provider_id: provider_id,
        delivered_at: status == :sent ? Time.current : nil)
    end

    counts = message.message_deliveries.group(:status).count
    sent = counts.fetch("sent", 0)
    captured = counts.fetch("captured", 0)
    final_status = sent.positive? ? :sent : (captured.positive? ? :captured : :failed)
    message.update!(status: final_status, sent_count: sent, captured_count: captured,
      failed_count: counts.fetch("failed", 0), skipped_count: counts.fetch("skipped", 0), sent_at: Time.current,
      error_message: counts.empty? ? "No eligible recipients" : nil)
  rescue StandardError => e
    if claimed == 1
      counts = message.message_deliveries.group(:status).count
      message.update!(status: :failed, sent_count: counts.fetch("sent", 0), failed_count: counts.fetch("failed", 0),
        captured_count: counts.fetch("captured", 0), skipped_count: counts.fetch("skipped", 0),
        error_message: "Sending interrupted (#{e.class.name}); reconcile pending deliveries with provider before resending")
    end
    raise
  end
end
