class CreateBudgetPeriods < ActiveRecord::Migration[8.0]
  def change
    create_table :budget_periods do |t|
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.timestamps
    end
    add_index :budget_periods, :start_date, unique: true
  end
end
