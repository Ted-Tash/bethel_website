class Conference < ApplicationRecord
  has_many :registrations,
    class_name: "ConferenceRegistration",
    dependent: :restrict_with_error,
    inverse_of: :conference
  has_many :questions,
    -> { order(:position, :id) },
    class_name: "ConferenceQuestion",
    dependent: :destroy,
    inverse_of: :conference

  has_many :admins,
    class_name: "ConferenceAdmin",
    dependent: :destroy,
    inverse_of: :conference

  accepts_nested_attributes_for :admins, allow_destroy: true, reject_if: :all_blank

  before_validation :normalize_slug

  validates :name, :slug, presence: true
  validates :slug,
    uniqueness: { case_sensitive: false },
    format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/, message: "may only contain lowercase letters, numbers, and hyphens" }
  validate :ends_after_start
  validate :admin_emails_are_unique

  scope :chronological, -> { order(starts_at: :desc, name: :asc) }

  def to_param
    slug
  end

  private

  def normalize_slug
    self.slug = slug.to_s.parameterize if slug.present?
  end

  def admin_emails_are_unique
    emails = admins.reject(&:marked_for_destruction?).map(&:email)
    errors.add(:admins, "must have different email addresses") if emails.uniq.size != emails.size
  end

  def ends_after_start
    return if starts_at.blank? || ends_at.blank? || ends_at > starts_at

    errors.add(:ends_at, "must be after the start time")
  end
end
