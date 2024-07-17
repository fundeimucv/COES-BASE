# == Schema Information
#
# Table name: catedradepartamentos
#
#  id              :bigint           not null, primary key
#  orden           :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  catedra_id      :string(255)
#  departamento_id :string(255)
#
class Catedradepartamento < ApplicationRecord
	# SET GLOBALES:
	# self.table_name = 'catedras_departamentos'

	belongs_to :departamento
	belongs_to :catedra

	validates_uniqueness_of :catedra_id, scope: [:departamento_id], message: 'Combinación Cátedra-Departamento ya existe', field_name: false
	
	# validates :orden,  presence: true

end
