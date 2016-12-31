class WithdrawDetail < ApplicationRecord
  before_update :update_customer_account

  protected

  def update_customer_account
    p 'a'*10,self
  end
end
