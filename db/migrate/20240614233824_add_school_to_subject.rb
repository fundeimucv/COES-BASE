class AddSchoolToSubject < ActiveRecord::Migration[7.0]
  def change
    # add_column :subjects, :school_id, :bigint
    add_reference :subjects, :school, foreign_key: true, index: true
  end
end
