class AddSectionToBudgetCategories < ActiveRecord::Migration[8.0]
  def change
    add_column :budget_categories, :section, :string, null: false, default: "spending"
  end
end
