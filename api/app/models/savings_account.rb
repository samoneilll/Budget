class SavingsAccount < ApplicationRecord
  belongs_to :pocketsmith_account, optional: true
  has_many :savings_snapshots,     dependent: :destroy
  has_many :savings_contributions, dependent: :destroy

  validates :name, presence: true

  def latest_snapshot
    savings_snapshots.order(date: :desc).first
  end

  def current_balance
    latest_snapshot&.balance
  end
end
