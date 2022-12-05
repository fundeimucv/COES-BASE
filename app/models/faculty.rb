class Faculty < ApplicationRecord
	has_many :schools

	validates :name, presence: true, unique: true
end
