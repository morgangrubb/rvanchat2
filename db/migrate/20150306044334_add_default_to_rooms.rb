class AddDefaultToRooms < ActiveRecord::Migration
  def change
    add_column :rooms, :default, :boolean, null: false, default: true
  end
end
