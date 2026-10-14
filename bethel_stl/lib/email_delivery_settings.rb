module EmailDeliverySettings
  def self.configure(config, environment:, env: ENV)
    live = environment == "production" || (environment == "development" && env["ALLOW_REAL_EMAIL_DELIVERY"] == "true")
    config.action_mailer.delivery_method = live ? :resend_checked : :file
    config.action_mailer.file_settings = { location: Rails.root.join("tmp/mail_capture") }
    config.action_mailer.perform_deliveries = true
    config.action_mailer.raise_delivery_errors = true
    config.action_mailer.default_url_options = if environment == "production"
      { host: env["MAILER_HOST"], protocol: "https" }
    else
      { host: env.fetch("MAILER_HOST", "localhost"), port: env.fetch("PORT", 4000), protocol: "http" }
    end
  end
end
