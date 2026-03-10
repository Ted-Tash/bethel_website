class Recording < ApplicationRecord
  include Documentable

  has_one_attached :audio
  has_one_attached :original_audio

  validates :title, presence: true
  validates :speaker_name, presence: true
end
