class SameDepartamentAreaOnSubjectValidator < ActiveModel::Validator
    def validate(record)
        if diferent_area_departament(record)
          record.errors.add "No es posible registrar la asignatura en departamentos", "y areas no vinculados"
        end
      end
    
      private
        def diferent_area_departament(record)
          !(record.departament&.areas.ids.include? record.area_id)
        end
end


