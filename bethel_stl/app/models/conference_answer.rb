class ConferenceAnswer < ApplicationRecord
  belongs_to :registration,
    class_name: "ConferenceRegistration",
    foreign_key: :conference_registration_id,
    inverse_of: :answers
  belongs_to :question,
    class_name: "ConferenceQuestion",
    foreign_key: :conference_question_id,
    inverse_of: :answers

  validates :conference_question_id, uniqueness: { scope: :conference_registration_id }
  validate :value_uses_available_choices

  def value=(input)
    normalized = input.is_a?(Array) ? input.reject(&:blank?).join("\n") : input
    super(normalized)
  end

  def selected_values
    value.to_s.lines.map(&:strip).reject(&:blank?)
  end

  def display_value
    question&.question_type == "multiple_choice" ? selected_values.join("; ") : value
  end

  private

  def value_uses_available_choices
    return if question.blank? || question.question_type.in?(%w[short_text long_text]) || value.blank?
    return if selected_values.all? { |item| item.in?(question.available_options) }

    errors.add(:value, "contains an unavailable choice")
  end
end
