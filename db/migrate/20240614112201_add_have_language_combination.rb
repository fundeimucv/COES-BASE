class AddHaveLanguageCombination < ActiveRecord::Migration[7.0]
  def change
    add_column :schools, :have_language_combination, :boolean, default: false, null: false
  end
end
