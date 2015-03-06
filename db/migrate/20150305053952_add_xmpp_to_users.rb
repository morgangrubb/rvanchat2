class AddXmppToUsers < ActiveRecord::Migration
  def change
    add_column :users, :name, :string
    add_column :users, :xmpp_username, :string
    add_column :users, :xmpp_password, :string

    add_index :users, :xmpp_username, unique: true
  end
end
