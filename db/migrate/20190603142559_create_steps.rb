class CreateSteps < ActiveRecord::Migration[5.2]
  def change
    create_table :steps do |t|
      t.references :city, foreign_key: true
      t.references :trip, foreign_key: true
      t.integer :duration
      t.integer :order
      t.integer :time_next_step
      t.integer :distance_next_step

      t.timestamps
    end
  end
end
