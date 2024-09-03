class AddSchoolReferenceToArea < ActiveRecord::Migration[7.0]
  def change
    add_reference :areas, :school, foreign_key: true, index: true
    up_only do
      Area.all.map{|ar| ar.update(school_id: ar.departaments_school_id)if !ar.departaments_school_id.nil?}
    end
  end
end
