class CreatePeriods < ActiveRecord::Migration[7.0]
  def change
    create_table :periods do |t|
      t.string :name
      t.integer :year
      t.integer :modality

      t.timestamps
    end
  end
end
