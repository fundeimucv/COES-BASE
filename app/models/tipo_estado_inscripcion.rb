# == Schema Information
#
# Table name: tipo_estado_inscripciones
#
#  id          :string(255)      not null, primary key
#  descripcion :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class TipoEstadoInscripcion < ApplicationRecord

	self.table_name = 'tipo_estado_inscripciones'	
	RESERVADO = 'RES'
	PREINSCRITO = 'PRE'
	INSCRITO = 'INS'
	REINCORPODADO = 'REINC'
	RETIRADA = 'RET'
	# ASOCIACIONES:
	has_many :inscripcionsecciones
	accepts_nested_attributes_for :inscripcionsecciones

	# VALIDACIONES:
    validates :id, presence: true, uniqueness: true

	def inscrito?
		id.eql? INSCRITO
	end

	def preinscrito?
		id.eql? PREINSCRITO
	end

	def reservado?
		id.eql? RESERVADO
	end
end
