# == Schema Information
#
# Table name: adjuntos
#
#  id             :bigint           not null, primary key
#  name           :string(255)      not null
#  record_type    :string(255)      not null
#  created_at     :datetime         not null
#  adjuntoblob_id :bigint           not null
#  record_id      :bigint           not null
#
class Adjunto < ApplicationRecord
	
	belongs_to :adjuntoblob, primary_key: :id

end
