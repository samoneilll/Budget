class CreateSavingsAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :savings_accounts do |t|
      t.string  :name, null: false
      t.references :pocketsmith_account, null: true, foreign_key: true
      t.decimal :fortnightly_contribution_target, precision: 12, scale: 2
      t.timestamps
    end
  end
end
