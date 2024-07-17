class AddLanguagesToGrade < ActiveRecord::Migration[7.0]
  def change
    add_column :grades, :language1_id, :bigint
    add_column :grades, :language2_id, :bigint
    add_foreign_key "grades", "languages", column: 'language1_id', on_update: :cascade, on_delete: :nullify
    add_foreign_key "grades", "languages", column: 'language2_id', on_update: :cascade, on_delete: :nullify
  end
end
