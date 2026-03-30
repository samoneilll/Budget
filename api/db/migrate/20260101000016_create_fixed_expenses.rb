class CreateFixedExpenses < ActiveRecord::Migration[8.0]
  def change
    create_table :fixed_expenses do |t|
      t.string  :name,               null: false
      t.decimal :fortnightly_amount, precision: 10, scale: 2, null: false, default: 0
      t.integer :position,           null: false, default: 0
      t.timestamps
    end
  end
end
