class CreatePartialQualifications < ActiveRecord::Migration[7.0]
  def change
    create_table :partial_qualifications do |t|
      t.decimal :value, precision: 4, scale: 2
      t.integer :partial, null: false, default: 1
      t.references :academic_record, null: false, foreign_key: true
      t.timestamps
    end
  end
end
