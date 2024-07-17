# == Schema Information
#
# Table name: languages
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_languages_on_name  (name) UNIQUE
#
class Language < ApplicationRecord
    validates :name, presence: true, uniqueness: true

    def short_name
        name[0..2].upcase
    end
end
