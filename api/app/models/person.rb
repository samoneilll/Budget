class Person < ApplicationRecord
  has_many :pocketsmith_accounts

  validates :name, presence: true, uniqueness: true

  scope :individuals, -> { where.not(name: "Household") }

  after_save :recalculate_pct_categories, if: :saved_change_to_fortnightly_income?

  def household?
    name == "Household"
  end

  private

  def recalculate_pct_categories
    sam_income = Person.find_by(name: "Sam")&.fortnightly_income || 0
    ish_income = Person.find_by(name: "Ish")&.fortnightly_income || 0

    BudgetCategory.unscoped.where.not(sam_pct: nil).or(BudgetCategory.unscoped.where.not(ish_pct: nil)).each do |cat|
      cat.sam_amount = (cat.sam_pct.to_f / 100.0 * sam_income).round(2) if cat.sam_pct.present?
      cat.ish_amount = (cat.ish_pct.to_f / 100.0 * ish_income).round(2) if cat.ish_pct.present?
      unless BudgetCategory::MANAGED.include?(cat.name)
        cat.fortnightly_amount = (cat.sam_amount.to_f + cat.ish_amount.to_f).round(2)
      end
      cat.save!
    end
  end

  public

  def income_share(among: Person.individuals)
    return 0 if household? || fortnightly_income.nil?
    total = among.sum(:fortnightly_income)
    return 0 if total.zero?
    (fortnightly_income / total).round(4)
  end
end
