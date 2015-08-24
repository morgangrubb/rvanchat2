class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :user_name
      t.integer :user_id
      t.string :room_name
      t.integer :room_id
      t.text :text

      t.timestamps null: false
    end

    add_index :messages, [:user_id, :created_at]
    add_index :messages, [:room_id, :created_at]
  end
end
