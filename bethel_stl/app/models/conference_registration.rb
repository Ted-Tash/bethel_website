class ConferenceRegistration < ApplicationRecord
  belongs_to :conference, inverse_of: :registrations
  has_many :answers,
    class_name: "ConferenceAnswer",
    dependent: :destroy,
    inverse_of: :registration

  accepts_nested_attributes_for :answers

  before_validation :normalize_contact_information
  after_create_commit :notify_conference_admins

  scope :active, -> { where(cancelled_at: nil) }
  scope :cancelled, -> { where.not(cancelled_at: nil) }

  validates :first_name, :last_name, :email, :phone, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
  validate :answers_belong_to_conference
  validate :required_questions_answered

  def full_name
    [ first_name, last_name ].compact_blank.join(" ")
  end

  def answer_for(question)
    answers.detect { |answer| answer.conference_question_id == question.id }
  end

  def cancelled?
    cancelled_at.present?
  end

  def cancel!
    update!(cancelled_at: Time.current) unless cancelled?
  end

  def reactivate!
    update!(cancelled_at: nil) if cancelled?
  end

  private

  def notify_conference_admins
    conference.admins.find_each do |admin|
      SendRegistrationMailerJob.perform_later(self, admin)
    end
  end

  def normalize_contact_information
    self.email = email.to_s.strip.downcase
    self.phone = phone.to_s.strip
  end

  def answers_belong_to_conference
    return if conference.blank?

    submitted_answers = answers.reject(&:marked_for_destruction?)
    submitted_questions = submitted_answers.map(&:question)
    valid_questions = submitted_questions.all? { |question| question.present? && question.conference_id == conference_id }
    unique_questions = submitted_questions.compact.uniq.length == submitted_answers.length
    return if valid_questions && unique_questions

    errors.add(:answers, "must match this conference's questions")
  end

  def required_questions_answered
    return if conference.blank?

    conference.questions.select(&:required?).each do |question|
      answer = answers.reject(&:marked_for_destruction?).find { |item| item.conference_question_id == question.id }
      errors.add(:base, "#{question.label} is required") if answer.blank? || answer.value.blank?
    end
  end
end
