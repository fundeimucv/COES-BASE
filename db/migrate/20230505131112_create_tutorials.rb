class CreateTutorials < ActiveRecord::Migration[7.0]
  def change
    create_table :tutorials do |t|
      t.string :name_function

      t.timestamps
    end
  end
end
