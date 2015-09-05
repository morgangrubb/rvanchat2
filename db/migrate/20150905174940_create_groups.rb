class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :name
      t.boolean :default, default: false

      t.timestamps null: false
    end

    execute %(INSERT INTO groups SET name = "rvan", `default` = 1, created_at = NOW(), updated_at = NOW())
  end
end
