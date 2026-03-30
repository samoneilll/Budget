class MortgageSnapshot < ApplicationRecord
  belongs_to :mortgage

  validates :date, :balance, presence: true
  validates :date, uniqueness: { scope: :mortgage_id }

  scope :recent, -> { order(date: :desc) }
end
