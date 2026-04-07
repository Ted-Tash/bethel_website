class SendMessageJob < ApplicationJob
  queue_as :default

  def perform(message_id)
    message = Message.find_by(id: message_id)
    return unless message
    return unless message.scheduled? # guard against re-sends or cancelled messages

    message.update!(status: :sending)

    recipients = if message.contact_group
      message.contact_group.members.with_phone
    else
      Member.with_phone
    end

    recipients.find_each do |member|
      delivery = message.message_deliveries.create!(
        member: member,
        phone_or_email: member.normalized_phone,
        status: :pending
      )

      result = TwilioSmsService.send_sms(
        to: delivery.phone_or_email,
        body: message.body
      )

      if result.success?
        delivery.update!(status: :sent, delivered_at: Time.current)
        message.increment!(:sent_count)
      else
        delivery.update!(status: :failed, error_message: result.error)
        message.increment!(:failed_count)
      end
    end

    final_status = message.sent_count > 0 ? :sent : :failed
    message.update!(status: final_status, sent_at: Time.current)
  end
end
