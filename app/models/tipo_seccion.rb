class TipoSeccion < ApplicationRecord
	self.table_name = 'tipo_secciones'
	FINAL = 'NF'
	SUFICIENCIA = 'NS'
	EQ_EXTERNA = 'EE'
	EQ_INTERNA = 'EI'

	# ASOCIACIONES
	has_many :secciones
	accepts_nested_attributes_for :secciones

	# VALIDACIONES
	validates :id, presence: true, uniqueness: true
	validates :descripcion, presence: true

end
