class FacultyBankAccount < ApplicationRecord
    belongs_to :faculty
    belongs_to :bank_account

    rails_admin do
        visible false
    end

end
