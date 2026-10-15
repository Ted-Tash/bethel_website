class ConferenceRegistrationMailer < ApplicationMailer
  def registration_details(registration, admin)
    EmailConfiguration.validate!
    @conference = registration.conference
    registration.answers.load
    @details = [
      [ "Name", registration.full_name ],
      [ "Email", registration.email ],
      [ "Phone", registration.phone ],
      [ "Submitted", registration.created_at.to_fs(:long) ]
    ]
    @conference.questions.each do |question|
      @details << [ question.label, registration.answer_for(question)&.display_value.presence || "—" ]
    end

    mail(to: admin.email, reply_to: registration.email,
      subject: "New registration for #{@conference.name}: #{registration.full_name}",
      options: { idempotency_key: "conference-registration-#{registration.id}-admin-#{admin.id}" })
  end
end
