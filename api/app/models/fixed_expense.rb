class FixedExpense < ApplicationRecord
  validates :name, presence: true
  validates :fortnightly_amount, numericality: true

  default_scope { order(:position, :name) }

  after_save    :sync_outgoing_category
  after_destroy :sync_outgoing_category

  private

  def sync_outgoing_category
    outgoing = BudgetCategory.find_by(name: "Outgoing")
    return unless outgoing

    total = FixedExpense.sum(:fortnightly_amount)
    sam   = Person.find_by(name: "Sam")
    ish   = Person.find_by(name: "Ish")

    total_income = (sam&.fortnightly_income || 0) + (ish&.fortnightly_income || 0)
    sam_share = total_income > 0 ? (sam&.fortnightly_income || 0) / total_income : 0
    ish_share = total_income > 0 ? (ish&.fortnightly_income || 0) / total_income : 0

    outgoing.update_columns(
      fortnightly_amount: total.round(2),
      sam_amount:         (total * sam_share).round(2),
      ish_amount:         (total * ish_share).round(2)
    )
  end
end
