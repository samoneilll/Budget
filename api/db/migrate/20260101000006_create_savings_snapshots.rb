class CreateSavingsSnapshots < ActiveRecord::Migration[8.0]
  def change
    create_table :savings_snapshots do |t|
      t.references :savings_account, null: false, foreign_key: true
      t.date    :date, null: false
      t.decimal :balance, precision: 12, scale: 2, null: false
      t.timestamps
    end
    add_index :savings_snapshots, [:savings_account_id, :date], unique: true
  end
end
