class TwilioSmsService
  Result = Struct.new(:success?, :sid, :error, keyword_init: true)

  def self.send_sms(to:, body:)
    account_sid = Rails.application.credentials.dig(:twilio, :account_sid)
    auth_token = Rails.application.credentials.dig(:twilio, :auth_token)
    from_number = Rails.application.credentials.dig(:twilio, :phone_number)

    if account_sid.blank? || auth_token.blank? || from_number.blank?
      return Result.new(success?: false, error: "Twilio credentials not configured")
    end

    client = Twilio::REST::Client.new(account_sid, auth_token)
    message = client.messages.create(
      from: from_number,
      to: to,
      body: body
    )

    Result.new(success?: true, sid: message.sid)
  rescue Twilio::REST::TwilioError => e
    Result.new(success?: false, error: e.message)
  rescue StandardError => e
    Result.new(success?: false, error: "Unexpected error: #{e.message}")
  end
end
