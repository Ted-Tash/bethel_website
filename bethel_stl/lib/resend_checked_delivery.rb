require "resend/mailer"

# The SDK adapter can return an error or an empty response without raising.
# Never interpret those responses as provider acceptance.
class ResendCheckedDelivery < Resend::Mailer
  def deliver!(mail)
    response = super
    unless response[:error].nil? && response[:id].present?
      raise Resend::Error, "Resend did not return an accepted email ID"
    end
    response
  end
end
