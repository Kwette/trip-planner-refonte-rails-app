class CreateActivities < ActiveRecord::Migration[5.2]
  def change
    create_table :activities do |t|
      t.string :address
      t.integer :duration
      t.references :city, foreign_key: true
      t.json :activity_types
      t.string :name
      t.float :ranking_interest
      t.string :photo
      t.text :description
      t.integer :price

      t.timestamps
    end
  end
end
