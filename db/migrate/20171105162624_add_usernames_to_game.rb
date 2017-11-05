class AddUsernamesToGame < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :usernames, :json
  end
end
