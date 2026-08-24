class Guide < ApplicationRecord
  has_rich_text :body

  validates :title, :slug, :summary, presence: true
  validates :slug, uniqueness: true, format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/ }

  scope :ordered, -> { order(:position, :title) }

  def to_param = slug
end
