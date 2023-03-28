class AddUpdatedPasswordToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :updated_password, :boolean, default: false
  end
end
