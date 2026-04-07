class Event < ApplicationRecord
  belongs_to :calendar_source

  validates :title, presence: true
  validates :starts_at, presence: true
  validates :google_event_id, uniqueness: { scope: :calendar_source_id }, allow_nil: true

  scope :upcoming, -> { where("starts_at >= ?", Time.current).order(starts_at: :asc) }
  scope :visible, -> { where(public: true) }
  scope :upcoming_public, -> { visible.upcoming }
end
