class AddDesWebToUser < ActiveRecord::Migration
  def change
    add_column :users, :website, :string
    add_column :users, :description, :text
    add_column :users, :address, :string
  end
end
