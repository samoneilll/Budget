class Mortgage < ApplicationRecord
  belongs_to :pocketsmith_account, optional: true
  has_many :mortgage_snapshots, dependent: :destroy
  has_many :lvr_milestones,     dependent: :destroy

  validates :original_principal, numericality: { greater_than: 0 }

  def current_balance
    mortgage_snapshots.order(date: :desc).first&.balance
  end

  def lvr
    return nil unless property_value.present? && current_balance
    (current_balance / property_value).round(4)
  end
end
