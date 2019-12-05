class AddMisteryToTrip < ActiveRecord::Migration[5.2]
  def change
    add_column :trips, :percentage_of_mistery, :integer
  end
end
