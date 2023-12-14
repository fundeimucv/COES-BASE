class RequirementBySubjectType < ApplicationRecord
    belongs_to :study_plan
    belongs_to :subject_type

    validates :study_plan, presence: true
    validates :subject_type, presence: true
    validates :required_credits, presence: true, numericality: { only_integer: true, in: 0..1000 }

    def name
        "#{subject_type.name} (#{required_credits} CRED)"
    end

    rails_admin do
        visible false

        edit do
            fields :subject_type, :required_credits

        end
    end
end
