# == Schema Information
#
# Table name: combinaciones
#
#  id            :bigint           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  estudiante_id :string(255)
#  idioma1_id    :string(255)
#  idioma2_id    :string(255)
#  periodo_id    :string(255)
#
class Combinacion < ApplicationRecord
	# ASOCIACIONES:
	self.table_name = 'combinaciones'

	belongs_to :estudiante, primary_key: :usuario_id
	belongs_to :periodo
	
	belongs_to :idioma1,
	class_name: 'Departamento',
	foreign_key: :idioma1_id
	accepts_nested_attributes_for :idioma1
	
	belongs_to :idioma2,
	class_name: 'Departamento',
	foreign_key: :idioma2_id
	accepts_nested_attributes_for :idioma2

	# VALIDACIONES:
	validates :estudiante_id, presence: true
	validates :periodo_id, presence: true
	validates :idioma1_id, presence: true
	validates :idioma2_id, presence: true
	validates_uniqueness_of :estudiante_id, scope: [:periodo_id], message: 'Ya existe una combinación de idiomas para éste periodo. Por favor edite la existente y cambie sus respectivos idiomas.', field_name: false

	# FUNCIONES:
	def descripcion
		desc1 = idioma1.descripcion if idioma1
		desc2 = idioma2.descripcion if idioma2
		"#{desc1} / #{desc2} - #{periodo_id}"
	end

end
