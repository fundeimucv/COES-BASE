# == Schema Information
#
# Table name: tipoasignaturas
#
#  id          :string(255)      not null, primary key
#  descripcion :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Tipoasignatura < ApplicationRecord
	# Relaciones:
	has_many :asignaturas

	PROYECTO = 'P'


	# Validaciones:
	validates :id, presence: true
	validates :descripcion, presence: true

	before_save :set_downcase_descripcion

	def find_subject_type
		SubjectType.where(code: self.id).first
	end

	def set_downcase_descripcion
		self.descripcion = self.descripcion.downcase
	end
end
