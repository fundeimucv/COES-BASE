class CreateAdmins < ActiveRecord::Migration[7.0]
  def change
    create_table :admins do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :role
      t.bigint  :environme_authorize_id
      t.string  :environme_authorize_type      

      t.timestamps
    end
  end
end
