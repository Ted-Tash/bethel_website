class AudioExtraction < ApplicationRecord
  has_one_attached :audio_file

  validates :youtube_url, presence: true,
    format: { with: /\A(https?:\/\/)?(www\.)?(youtube\.com|youtu\.be)\/.+\z/, message: 'must be a valid YouTube URL' }

  scope :recent, -> { order(created_at: :desc) }

  STATUSES = %w[pending processing completed failed].freeze

  validates :status, inclusion: { in: STATUSES }

  def pending? = status == 'pending'
  def processing? = status == 'processing'
  def completed? = status == 'completed'
  def failed? = status == 'failed'

  def in_progress? = pending? || processing?

  def time_range
    return nil unless start_time.present? || end_time.present?
    "*#{start_time.presence || '00:00:00'}-#{end_time.presence || 'inf'}"
  end

  def display_name
    filename.presence || "extraction-#{id}"
  end
end
