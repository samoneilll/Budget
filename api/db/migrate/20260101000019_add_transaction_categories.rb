class AddTransactionCategories < ActiveRecord::Migration[8.0]
  def up
    create_table :transaction_categories do |t|
      t.string     :name, null: false
      t.references :budget_category, null: false, foreign_key: true
      t.timestamps
    end
    add_index :transaction_categories, :name, unique: true

    # Seed one catch-all transaction category per budget category to preserve existing data
    execute <<~SQL
      INSERT INTO transaction_categories (name, budget_category_id, created_at, updated_at)
      SELECT name, id, NOW(), NOW()
      FROM budget_categories
    SQL

    add_reference :transactions, :transaction_category, null: true, foreign_key: true

    # Migrate existing transaction → budget_category links to the new catch-all categories
    execute <<~SQL
      UPDATE transactions
      SET transaction_category_id = (
        SELECT tc.id FROM transaction_categories tc
        WHERE tc.budget_category_id = transactions.budget_category_id
        LIMIT 1
      )
      WHERE budget_category_id IS NOT NULL
    SQL

    remove_reference :transactions, :budget_category, foreign_key: true
  end

  def down
    add_reference :transactions, :budget_category, null: true, foreign_key: true

    execute <<~SQL
      UPDATE transactions
      SET budget_category_id = (
        SELECT tc.budget_category_id FROM transaction_categories tc
        WHERE tc.id = transactions.transaction_category_id
        LIMIT 1
      )
      WHERE transaction_category_id IS NOT NULL
    SQL

    remove_reference :transactions, :transaction_category, foreign_key: true
    drop_table :transaction_categories
  end
end
