class BudgetCategory < ApplicationRecord
  MANAGED = %w[Outgoing Spending].freeze

  has_many :transactions, dependent: :nullify

  default_scope { order(:position, :name) }

  validates :name, presence: true, uniqueness: true
  validates :fortnightly_amount, numericality: true

  before_save :apply_pct_amounts,  if: -> { sam_pct_changed? || ish_pct_changed? }
  before_save :sync_total,         unless: -> { MANAGED.include?(name) }

  private

  def apply_pct_amounts
    sam_income = Person.find_by(name: "Sam")&.fortnightly_income || 0
    ish_income = Person.find_by(name: "Ish")&.fortnightly_income || 0
    self.sam_amount = (sam_pct.to_f / 100.0 * sam_income).round(2) if sam_pct.present?
    self.ish_amount = (ish_pct.to_f / 100.0 * ish_income).round(2) if ish_pct.present?
  end

  def sync_total
    self.fortnightly_amount = (sam_amount.to_f + ish_amount.to_f).round(2)
  end
end
