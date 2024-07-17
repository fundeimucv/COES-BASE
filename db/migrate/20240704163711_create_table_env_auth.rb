class CreateTableEnvAuth < ActiveRecord::Migration[7.0]
  def change
    create_table :env_auths do |t|
      t.references :admin, null: false, foreign_key: {primary_key: :user_id, on_delete: :cascade, on_update: :cascade}
      t.references :env_authorizable, polymorphic: {default: 'School'}
      t.timestamps
    end
  end
end
