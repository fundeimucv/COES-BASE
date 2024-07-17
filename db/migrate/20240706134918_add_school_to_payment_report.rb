class AddSchoolToPaymentReport < ActiveRecord::Migration[7.0]
  def change
    add_reference :payment_reports, :school, foreign_key: true, index: true
    add_reference :payment_reports, :user, foreign_key: true, index: true
    up_only do
      PaymentReport.all.map{|pr| pr.update(school_id: pr.school_by_payable.id, user_id: pr.user_by_payable.id)}
    end
    
  end
end