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

  before_validation :normalize_slug

  validates :name, :slug, presence: true
  validates :slug,
    uniqueness: { case_sensitive: false },
    format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/, message: "may only contain lowercase letters, numbers, and hyphens" }
  validate :ends_after_start

  scope :chronological, -> { order(starts_at: :desc, name: :asc) }

  def to_param
    slug
  end

  private

  def normalize_slug
    self.slug = slug.to_s.parameterize if slug.present?
  end

  def ends_after_start
    return if starts_at.blank? || ends_at.blank? || ends_at > starts_at

    errors.add(:ends_at, "must be after the start time")
  end
end
