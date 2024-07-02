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
