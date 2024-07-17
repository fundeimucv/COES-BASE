# == Schema Information
#
# Table name: adjuntoblobs
#
#  id           :bigint           not null, primary key
#  byte_size    :bigint           not null
#  checksum     :string(255)      not null
#  content_type :string(255)
#  filename     :string(255)      not null
#  key          :string(255)      not null
#  metadata     :text
#  created_at   :datetime         not null
#
class Adjuntoblob < ApplicationRecord
    
    # has_one :adjunto, primary_key: :id
end
