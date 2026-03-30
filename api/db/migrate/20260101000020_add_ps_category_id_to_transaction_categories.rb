class AddPsCategoryIdToTransactionCategories < ActiveRecord::Migration[8.0]
  def change
    add_column :transaction_categories, :ps_category_id, :integer
    add_column :transactions, :ps_category_synced_at, :datetime
  end
end
