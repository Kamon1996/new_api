class AddSernameToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :sername, :string
  end
end
