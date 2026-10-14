class MemberMessageMailer < ApplicationMailer
  def broadcast(delivery)
    EmailConfiguration.validate!
    @message = delivery.message
    @unsubscribe_url = email_unsubscribe_url(token: EmailSuppression.token_for(delivery.phone_or_email))
    @postal_address = EmailConfiguration.postal_address
    headers["List-Unsubscribe"] = "<#{@unsubscribe_url}>"
    headers["List-Unsubscribe-Post"] = "List-Unsubscribe=One-Click"
    mail(to: delivery.phone_or_email, subject: @message.subject,
      options: { idempotency_key: "message-delivery-#{delivery.id}" })
  end
end
