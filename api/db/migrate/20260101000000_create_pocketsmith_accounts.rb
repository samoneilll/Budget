class CreatePocketsmithAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :pocketsmith_accounts do |t|
      t.string  :ps_id, null: false
      t.string  :name, null: false
      t.string  :number
      t.string  :account_type
      t.string  :institution
      t.decimal :current_balance, precision: 12, scale: 2
      t.date    :current_balance_date
      t.timestamps
    end
    add_index :pocketsmith_accounts, :ps_id, unique: true
  end
end
