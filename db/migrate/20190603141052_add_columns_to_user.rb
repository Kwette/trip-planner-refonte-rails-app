class AddColumnsToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :phone_number, :string
    add_column :users, :username, :string
    add_column :users, :photo, :string, default: 'avatar.jpeg'
  end
end
