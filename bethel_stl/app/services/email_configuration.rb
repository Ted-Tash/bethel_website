class EmailConfiguration
  class Error < StandardError; end

  def self.live?
    ApplicationMailer.delivery_method == :resend_checked
  end

  def self.sender
    return "Bethel STL Preview <preview@example.invalid>" unless live?

    Rails.application.credentials.dig(:resend, :from_address)
  end

  def self.validate!
    unless ApplicationMailer.perform_deliveries && ApplicationMailer.raise_delivery_errors
      raise Error, "Email delivery is disabled or errors are suppressed"
    end
    unless [ :file, :test, :resend_checked ].include?(ApplicationMailer.delivery_method)
      raise Error, "Unsupported email delivery method"
    end
    return unless live?
    if Rails.env.development? && ENV["ALLOW_REAL_EMAIL_DELIVERY"] != "true"
      raise Error, "Real development email requires ALLOW_REAL_EMAIL_DELIVERY=true"
    end

    if Rails.application.credentials.dig(:resend, :api_key).blank? || sender.blank?
      raise Error, "Resend api_key and verified from_address credentials are required"
    end
    host = ApplicationMailer.default_url_options[:host]
    if host.blank? || host.include?("/") || host == "example.com" || (Rails.env.production? && host == "localhost")
      raise Error, "MAILER_HOST must be the real application hostname"
    end
    if Rails.application.credentials.dig(:resend, :postal_address).blank?
      raise Error, "Resend postal_address credential is required for bulk email footer"
    end
  end

  def self.postal_address
    live? ? Rails.application.credentials.dig(:resend, :postal_address) : "Preview only — church postal address required for live email"
  end
end
