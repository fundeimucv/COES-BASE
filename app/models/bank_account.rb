class BankAccount < ApplicationRecord
  # t.string "code", null: false
  # t.string "holder", null: false
  # t.bigint "bank_id", null: false
  # t.bigint "school_id", null: false
  # t.integer "acount_type"

  # ENUMERIZE:
  enum account_type: [:ahorro, :corriente]

  # ASSOCIATIONS:
  belongs_to :bank
  belongs_to :school
  # has_one :school

  rails_admin do
    navigation_label 'Finanzas'
    navigation_icon 'fa-solid fa-piggy-bank'

    edit do
      field :school
      field :code do
        html_attributes do
          {:length => 20, :size => 20, :onInput => "$(this).val($(this).val().toUpperCase().replace(/[^0-9]/g,''))"}
        end
      end
      fields :holder, :bank, :account_type
    end
  end

end
