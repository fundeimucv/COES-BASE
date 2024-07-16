class AddSchoolReferenceToArea < ActiveRecord::Migration[7.0]
  def change
    add_reference :areas, :school, foreign_key: true
  end
end
