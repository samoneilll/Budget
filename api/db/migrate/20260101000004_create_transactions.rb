class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      # Phase 1 — raw from PocketSmith
      t.string  :ps_id, null: false
      t.date    :date, null: false
      t.string  :payee
      t.string  :original_payee
      t.string  :memo
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.string  :ps_type
      t.string  :status
      t.boolean :is_transfer, default: false
      t.references :pocketsmith_account, null: true, foreign_key: true
      t.string  :ps_category

      # Phase 2 — Claude Haiku categorisation
      t.string  :processing_status, null: false, default: "imported"
      t.string  :haiku_category
      t.decimal :haiku_confidence, precision: 5, scale: 4
      t.text    :haiku_reasoning
      t.boolean :haiku_is_transfer

      # User override
      t.references :budget_category, null: true, foreign_key: true
      t.boolean :manually_categorised, default: false

      t.timestamps
    end

    add_index :transactions, :ps_id, unique: true
    add_index :transactions, :processing_status
    add_index :transactions, :date
  end
end
