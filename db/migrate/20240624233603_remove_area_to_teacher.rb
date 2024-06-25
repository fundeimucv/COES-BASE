class RemoveAreaToTeacher < ActiveRecord::Migration[7.0]
  def change
        remove_index :teachers, name: :index_teachers_on_area_id
        remove_reference :teachers, :area
  end
end
