class LvrMilestone < ApplicationRecord
  belongs_to :mortgage

  validates :lvr_target, :label, presence: true
  validates :lvr_target, numericality: { greater_than: 0, less_than_or_equal_to: 1 }
  validates :lvr_target, uniqueness: { scope: :mortgage_id }

  scope :unachieved, -> { where(achieved_at: nil) }
  scope :achieved,   -> { where.not(achieved_at: nil) }
  scope :ordered,    -> { order(lvr_target: :asc) }

  def achieved?
    achieved_at.present?
  end

  def lvr_display
    "#{(lvr_target * 100).round(1)}%"
  end
end
