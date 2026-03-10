class Document < ApplicationRecord
  belongs_to :documentable, polymorphic: true

  has_one_attached :file

  validates :file, presence: true, on: :create
end
