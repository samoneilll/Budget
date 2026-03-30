class CreateLvrMilestones < ActiveRecord::Migration[8.0]
  def change
    create_table :lvr_milestones do |t|
      t.references :mortgage, null: false, foreign_key: true
      t.decimal  :lvr_target, precision: 5, scale: 4, null: false  # e.g. 0.8000 = 80%
      t.string   :label, null: false
      t.datetime :achieved_at
      t.timestamps
    end
    add_index :lvr_milestones, [:mortgage_id, :lvr_target], unique: true
  end
end
