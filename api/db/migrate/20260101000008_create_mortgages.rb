class CreateMortgages < ActiveRecord::Migration[8.0]
  def change
    create_table :mortgages do |t|
      t.decimal :original_principal, precision: 12, scale: 2, null: false
      t.decimal :property_value,     precision: 12, scale: 2           # nullable — not yet decided
      t.references :pocketsmith_account, null: true, foreign_key: true # nullable — not yet decided
      t.string  :label
      t.timestamps
    end
  end
end
