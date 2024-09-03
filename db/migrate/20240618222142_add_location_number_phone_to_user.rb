class AddLocationNumberPhoneToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :location_number_phone, :string
  end
end
