class BankAccountsService < BaseService

  def get_bank_accounts(customer)
    CommonService.response_format(ResponseCode.COMMON.OK, customer.bank_accounts)
  end

  def get_bank_account(bank_account)
    CommonService.response_format(ResponseCode.COMMON.OK, bank_account)
  end

  def create_bank_account(customer, bank_account_params)
    p 'a'*10,bank_account_params
    bank_account_params.as_json.delete("customer_id")
    p 'B'*10,bank_account_params
    Address.transaction do
      # 处理默认地址唯一性
      if bank_account_params[:is_default] == true
        customer.bank_accounts.collect{|bank_account| bank_account.update(is_default: false)}
      end

      bank_account = customer.bank_accounts.create!(bank_account_params)
      CommonService.response_format(ResponseCode.COMMON.OK, bank_account)
    end
  end

  def update_bank_account(bank_account, bank_account_params)
    Address.transaction do
      # 处理默认地址唯一性
      if bank_account_params[:is_default] == true
        BankAccount.where(customer_id: bank_account.customer_id).collect{|bank_account| bank_account.update(is_default: false)}
      end

      if bank_account.update!(bank_account_params)
        CommonService.response_format(ResponseCode.COMMON.OK, bank_account)
      else
        ResponseCode.COMMON.FAILED['message'] = bank_account.errors
        CommonService.response_format(ResponseCode.COMMON.FAILED)
      end
    end
  end

  def destory_bank_account(bank_account)
    BankAccount.where(customer_id: bank_account.customer_id).first.update(is_default: true)
    bank_account.destroy
    CommonService.response_format(ResponseCode.COMMON.OK)
  end

end