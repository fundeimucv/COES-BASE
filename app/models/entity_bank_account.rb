class EntityBankAccount < ApplicationRecord
    belongs_to :bank_accountable, polymorphic: true
    belongs_to :bank_account

    rails_admin do
        visible false
    end
end
