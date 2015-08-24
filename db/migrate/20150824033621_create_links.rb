class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.integer :message_id, null: false
      t.string :host, null: false
      t.text :url, null: false

      t.timestamps null: false
    end

    add_index :links, [:created_at]
    add_index :links, [:message_id]
  end
end
