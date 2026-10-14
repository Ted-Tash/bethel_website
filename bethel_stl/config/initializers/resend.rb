require Rails.root.join("lib/resend_checked_delivery")

# Lazy lookup keeps secretless image builds and local previews working.
Resend.api_key = -> { Rails.application.credentials.dig(:resend, :api_key) }
ActiveSupport.on_load(:action_mailer) do
  add_delivery_method :resend_checked, ResendCheckedDelivery
end
