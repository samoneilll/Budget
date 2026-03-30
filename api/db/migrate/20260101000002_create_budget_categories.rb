class CreateBudgetCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :budget_categories do |t|
      t.string :name, null: false
      t.decimal :fortnightly_amount, precision: 12, scale: 2, null: false, default: 0
      t.text :description
      t.timestamps
    end
    add_index :budget_categories, :name, unique: true
  end
end
