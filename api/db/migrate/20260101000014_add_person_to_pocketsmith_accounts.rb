class AddPersonToPocketsmithAccounts < ActiveRecord::Migration[8.0]
  def change
    add_reference :pocketsmith_accounts, :person, null: true, foreign_key: true
  end
end
