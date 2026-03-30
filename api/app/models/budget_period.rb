class BudgetPeriod < ApplicationRecord
  has_many :savings_contributions, dependent: :destroy

  validates :start_date, :end_date, presence: true
  validate :end_after_start

  scope :current, -> { where("start_date <= ? AND end_date >= ?", Date.today, Date.today) }
  scope :recent,  -> { order(start_date: :desc) }

  def self.for_date(date)
    where("start_date <= ? AND end_date >= ?", date, date).first
  end

  # Generate fortnightly periods covering all transactions, centred on anchor_date.
  def self.generate_from_anchor(anchor_date)
    anchor = anchor_date.to_date
    earliest = Transaction.minimum(:date)&.to_date || anchor

    # Walk back from anchor to cover earliest transaction
    start = anchor
    start -= 14.days while start > earliest

    while start <= Date.today
      find_or_create_by(start_date: start) { |p| p.end_date = start + 13.days }
      start += 14.days
    end
  end

  private

  def end_after_start
    return unless end_date && start_date
    errors.add(:end_date, "must be after start_date") if end_date <= start_date
  end
end
