class AddPartialQualificationToSchool < ActiveRecord::Migration[7.0]
  def change
    add_column :schools, :have_partial_qualification, :boolean, default: false, null: false
  end
end
