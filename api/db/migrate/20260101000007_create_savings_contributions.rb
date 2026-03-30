class CreateSavingsContributions < ActiveRecord::Migration[8.0]
  def change
    create_table :savings_contributions do |t|
      t.references :savings_account, null: false, foreign_key: true
      t.references :budget_period,   null: false, foreign_key: true
      t.decimal :opening_balance, precision: 12, scale: 2
      t.decimal :closing_balance, precision: 12, scale: 2
      t.decimal :contribution,    precision: 12, scale: 2
      t.timestamps
    end
    add_index :savings_contributions, [:savings_account_id, :budget_period_id],
              unique: true, name: "idx_savings_contributions_account_period"
  end
end
