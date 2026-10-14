class ResendEmailService
  Result = Struct.new(:status, :provider_id, :error, keyword_init: true)

  def self.send_email(delivery:)
    unless delivery.member.reload.email_consent?
      return Result.new(status: :skipped, error: "Email consent withdrawn")
    end
    if EmailSuppression.exists?(email: delivery.phone_or_email)
      return Result.new(status: :skipped, error: "Email address unsubscribed")
    end
    unless delivery.phone_or_email.match?(URI::MailTo::EMAIL_REGEXP)
      return Result.new(status: :failed, error: "Invalid email address")
    end

    EmailConfiguration.validate!
    # Stay below Resend's default two requests/second for serialized mass jobs.
    sleep 0.6 if EmailConfiguration.live?
    mail = MemberMessageMailer.broadcast(delivery).deliver_now
    if EmailConfiguration.live?
      Result.new(status: :sent, provider_id: mail.message_id)
    else
      Result.new(status: :captured)
    end
  rescue EmailConfiguration::Error => e
    Result.new(status: :failed, error: e.message)
  rescue StandardError => e
    # Provider errors can contain recipient addresses or other sensitive data.
    Result.new(status: :failed, error: "Email delivery failed (#{e.class.name})")
  end
end
