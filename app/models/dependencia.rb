class Dependencia < ApplicationRecord
  belongs_to :asignatura
  belongs_to :asignatura_dependiente, class_name: 'Asignatura', foreign_key: 'asignatura_dependiente_id'

  # before_destroy :destroy_dependientes

  validates_uniqueness_of :asignatura_id, scope: [:asignatura_dependiente_id], message: 'la relación ya existe', field_name: false

  validates_with DependenciaAnidadaValidator, field_name: false

  # OJO: NO HACE FALTA PODAR TODO EL ARBOL DERIVADO DE DEPENDENCIAS, SOLO SE NECESITA ELIMINAR LA DEPENDENCIA DIRECTA.
  # def destroy_dependientes
  #   asignatura_dependiente.dependencias.destroy_all
  # end

end
