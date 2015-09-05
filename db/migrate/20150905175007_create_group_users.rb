class CreateGroupUsers < ActiveRecord::Migration
  def change
    create_table :group_users do |t|
      t.integer :group_id
      t.integer :user_id

      t.timestamps null: false
    end

    add_index :group_users, :group_id
    add_index :group_users, :user_id

    # Add everybody to every group
    execute <<-SQL
      INSERT INTO group_users (group_id, user_id, created_at, updated_at)
      SELECT groups.id, users.id, NOW(), NOW()
      FROM groups, users
      WHERE groups.default = 1
    SQL
  end
end
