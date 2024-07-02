# == Schema Information
#
# Table name: seccion_profesores_secundarios
#
#  id          :bigint           not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  profesor_id :string(255)
#  seccion_id  :bigint
#
class SeccionProfesorSecundario < ApplicationRecord
	self.table_name = 'seccion_profesores_secundarios'

	belongs_to :seccion
	belongs_to :profesor, primary_key: :usuario_id

	validates_uniqueness_of :profesor_id, scope: [:seccion_id], message: 'Profesor secundario ya existe para esta sección', field_name: false

	validates :seccion_id,  presence: true
	validates :profesor_id,  presence: true

end
