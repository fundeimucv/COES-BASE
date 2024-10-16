class AddDepartamentReferenceToSubject < ActiveRecord::Migration[7.0]
  def change
    add_reference :subjects, :departament, foreign_key: true, index: true
  end
end
