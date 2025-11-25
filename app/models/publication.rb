class Publication < ApplicationRecord
  belongs_to :user

  STATUSES = %w[draft published archived].freeze

  validates :title, presence: true
  validates :status, inclusion: { in: STATUSES }

  scope :active, -> { where(deleted_at: nil) }
  scope :published_only, -> { where(status: 'published', deleted_at: nil) }
  scope :search, -> (q) { where("title ILIKE ?", "%#{q}%") if q.present? }
  scope :status_filter, -> (stat) { where(status: stat) if stat.present? }
end
