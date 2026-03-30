class CreateMortgageSnapshots < ActiveRecord::Migration[8.0]
  def change
    create_table :mortgage_snapshots do |t|
      t.references :mortgage, null: false, foreign_key: true
      t.date    :date, null: false
      t.decimal :balance, precision: 12, scale: 2, null: false
      t.timestamps
    end
    add_index :mortgage_snapshots, [:mortgage_id, :date], unique: true
  end
end
