class CreateLocations < ActiveRecord::Migration[7.0]
  def change
    create_table :locations do |t|
      t.references :student, null: false, foreign_key: true, index: true, unique: true
      t.string :state
      t.string :municipality
      t.string :city
      t.string :sector
      t.string :street
      t.integer :house_type
      t.string :house_name

      t.timestamps
    end
  end
end
