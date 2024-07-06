class SameTypesValidator < ActiveModel::Validator
    def validate(record)
        if diferent_types(record)
            record.errors.add "No es posible asociar diferentes tipos de entornos:", "o Escuelas o Departamentos"
        end
    end

  private
    def diferent_types(record)
        aux = record.admin.env_auths.map(&:env_authorizable_type).uniq
        !(aux.include? record.env_authorizable_type)
    end
end
