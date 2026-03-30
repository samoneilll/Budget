class AddPositionAndPctToBudgetCategories < ActiveRecord::Migration[8.0]
  def change
    add_column :budget_categories, :position, :integer, null: false, default: 0
    add_column :budget_categories, :sam_pct,  :decimal, precision: 8, scale: 4
    add_column :budget_categories, :ish_pct,  :decimal, precision: 8, scale: 4
  end
end
