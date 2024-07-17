# == Schema Information
#
# Table name: planes
#
#  id          :string(255)      not null
#  creditos    :integer
#  descripcion :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  escuela_id  :string(255)      not null
#
class Plan < ApplicationRecord
	self.table_name = 'planes'
	# ASOCIACIONES:
	has_many :historialplanes
	accepts_nested_attributes_for :historialplanes

	belongs_to :escuela

	has_many :estudiantes, through: :historialplanes, source: :estudiante

	# VALIDACIONES:
    validates :id, presence: true, uniqueness: true
    validates :escuela_id, presence: true

    #TRIGGERS
    before_save :set_to_upcase

	# FUNCIONES:
	def descripcion_filtro
		self.descripcion_completa_con_escuela		
	end


	def descripcion_completa
		"#{id} - #{descripcion.titleize}"
	end

	def descripcion_completa_con_escuela
		"#{id} - #{descripcion.titleize} (#{escuela.descripcion})"
	end


	# FUNCIONES PROTEGIDAS
	protected

	def set_to_upcase
		self.descripcion = self.descripcion.upcase
	end
end
