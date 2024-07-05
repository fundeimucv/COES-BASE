# == Schema Information
#
# Table name: tipo_calificaciones
#
#  id          :string(255)      not null, primary key
#  descripcion :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_tipo_calificaciones_on_id  (id)
#
class TipoCalificacion < ApplicationRecord
	self.table_name = 'tipo_calificaciones'
	REPARACION = 'NR'
	PARCIAL = 'PR'
	DIFERIDO = 'ND'
	FINAL = 'NF'
	PI = 'PI'
	# ASOCIACIONES:
	has_many :inscripcionsecciones
	accepts_nested_attributes_for :inscripcionsecciones

	# VALIDACIONES:
	validates :id, presence: true, uniqueness: true

end
