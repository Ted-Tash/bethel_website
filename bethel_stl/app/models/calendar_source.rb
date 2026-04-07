class CalendarSource < ApplicationRecord
  has_many :events, dependent: :destroy

  validates :name, presence: true
  validates :google_calendar_id, presence: true, uniqueness: true

  def to_s
    name
  end
end
