class AddRegionToGrade < ActiveRecord::Migration[7.0]
  def change
    add_column :grades, :region, :integer, default: 0
  end
end
