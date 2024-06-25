class AddDeapartamentToTeacherAndDeleteArea < ActiveRecord::Migration[7.0]
  def change
    add_reference :teachers, :departament, foreign_key: true, index: true
  end
end
