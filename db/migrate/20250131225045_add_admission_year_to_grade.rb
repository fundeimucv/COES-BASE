class AddAdmissionYearToGrade < ActiveRecord::Migration[7.0]
  def change
    add_column :grades, :admission_year, :integer
  end
end
