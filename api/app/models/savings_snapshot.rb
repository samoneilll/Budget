class SavingsSnapshot < ApplicationRecord
  belongs_to :savings_account

  validates :date, :balance, presence: true
  validates :date, uniqueness: { scope: :savings_account_id }

  scope :recent,  -> { order(date: :desc) }
  scope :between, ->(from, to) { where(date: from..to) }
end
