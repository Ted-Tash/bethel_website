class SendRegistrationMailerJob < ApplicationJob
  queue_as :default
  limits_concurrency key: "registration-notifications", to: 1, duration: 5.minutes
  discard_on ActiveJob::DeserializationError

  def perform(registration, admin)
    EmailConfiguration.validate!
    sleep 0.6 if EmailConfiguration.live?
    ConferenceRegistrationMailer.registration_details(registration, admin).deliver_now
  end
end
