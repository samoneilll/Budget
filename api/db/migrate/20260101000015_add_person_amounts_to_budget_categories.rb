class AddPersonAmountsToBudgetCategories < ActiveRecord::Migration[8.0]
  def change
    add_column :budget_categories, :sam_amount, :decimal, precision: 10, scale: 2
    add_column :budget_categories, :ish_amount, :decimal, precision: 10, scale: 2
  end
end
