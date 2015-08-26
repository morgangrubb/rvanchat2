class AddAdminTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :admin_token, :string
  end
end
