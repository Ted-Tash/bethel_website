class ConferenceQuestion < ApplicationRecord
  TYPES = {
    "short_text" => "Short text",
    "long_text" => "Long text",
    "single_choice" => "Single choice",
    "multiple_choice" => "Multiple choice",
    "yes_no" => "Yes / No"
  }.freeze
  CHOICE_TYPES = %w[single_choice multiple_choice].freeze

  belongs_to :conference, inverse_of: :questions
  has_many :answers,
    class_name: "ConferenceAnswer",
    dependent: :restrict_with_error,
    inverse_of: :question

  before_validation :normalize_choices

  validates :label, presence: true, uniqueness: { scope: :conference_id, case_sensitive: false }
  validates :question_type, inclusion: { in: TYPES.keys }
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :choice_questions_have_options

  def choice_options
    choices.to_s.lines.map(&:strip).reject(&:blank?).uniq
  end

  def choice_options=(options)
    self.choices = Array(options).map { |option| option.to_s.strip }.reject(&:blank?).uniq.join("\n")
  end

  def choice_type?
    question_type.in?(CHOICE_TYPES)
  end

  def available_options
    question_type == "yes_no" ? [ "Yes", "No" ] : choice_options
  end

  private

  def normalize_choices
    self.choices = choice_type? ? choice_options.join("\n") : nil
  end

  def choice_questions_have_options
    return unless choice_type? && choice_options.length < 2

    errors.add(:choices, "must contain at least two options, one per line")
  end
end
