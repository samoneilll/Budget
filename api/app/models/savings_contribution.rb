class SavingsContribution < ApplicationRecord
  belongs_to :savings_account
  belongs_to :budget_period

  validates :savings_account_id, uniqueness: { scope: :budget_period_id }

  # Derives and upserts a contribution record from snapshot data.
  def self.calculate_for_period(savings_account, period)
    opening = SavingsSnapshot
      .where(savings_account: savings_account, date: ..period.start_date)
      .order(date: :desc).first&.balance

    closing = SavingsSnapshot
      .where(savings_account: savings_account, date: ..period.end_date)
      .order(date: :desc).first&.balance

    return unless opening && closing

    find_or_initialize_by(savings_account: savings_account, budget_period: period).tap do |sc|
      sc.opening_balance = opening
      sc.closing_balance = closing
      sc.contribution    = closing - opening
      sc.save!
    end
  end
end
