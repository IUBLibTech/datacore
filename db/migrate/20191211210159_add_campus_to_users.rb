class AddCampusToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :campus, :string
  end
end
