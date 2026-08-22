require "csv"

class ConferenceRegistrationsCsv
  def initialize(conference, registrations: conference.registrations)
    @registrations = registrations
    @questions = conference.questions.to_a
  end

  def generate
    CSV.generate(headers: true) do |csv|
      csv << [ "Registration ID", "Submitted At", "Status", "Cancelled At", "First Name", "Last Name", "Email", "Phone", *@questions.map { |question| spreadsheet_safe(question.label) } ]

      @registrations.includes(answers: :question).reorder(nil).find_each do |registration|
        answers_by_question = registration.answers.index_by(&:conference_question_id)
        csv << [
          registration.id,
          registration.created_at.iso8601,
          registration.cancelled? ? "Cancelled" : "Active",
          registration.cancelled_at&.iso8601,
          spreadsheet_safe(registration.first_name),
          spreadsheet_safe(registration.last_name),
          spreadsheet_safe(registration.email),
          spreadsheet_safe(registration.phone),
          *@questions.map { |question| spreadsheet_safe(answers_by_question[question.id]&.display_value) }
        ]
      end
    end
  end

  private

  def spreadsheet_safe(value)
    value.to_s.match?(/\A[=+\-@]/) ? "'#{value}" : value
  end
end
