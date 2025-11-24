class Publication < ApplicationRecord
  belongs_to :user

  STATUSES = %w[draft published archived].freeze

  validates :title, presence: true
  validates :status, inclusion: { in: STATUSES }

  scope :not_deleted, -> { where(deleted_at: nil) }
end
