class CreateTrips < ActiveRecord::Migration[5.2]
  def change
    create_table :trips do |t|
      t.references :user, foreign_key: true
      t.references :arrival_city, foreign_key: {to_table: :cities}
      t.references :departure_city, foreign_key: {to_table: :cities}
      t.datetime :start_date
      t.datetime :end_date
      t.json :criteria

      t.timestamps
    end
  end
end
