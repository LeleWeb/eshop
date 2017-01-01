class WithdrawDetailsService < BaseService

  def get_withdraw_details(customer)
    CommonService.response_format(ResponseCode.COMMON.OK, customer.withdraw_details.order(created_at: :desc))
  end

  def get_withdraw_detail(withdraw_detail)
    CommonService.response_format(ResponseCode.COMMON.OK, withdraw_detail)
  end

  def create_withdraw_detail(customer, store, withdraw_detail_params)
    withdraw_detail_params = withdraw_detail_params.as_json.merge("operate_time" => Time.now,
                                                                  "status" => Settings.WITHDRAW.APPLYING)
    withdraw_detail = customer.withdraw_details.create!(withdraw_detail_params)
    store.withdraw_details << withdraw_detail
    CommonService.response_format(ResponseCode.COMMON.OK, withdraw_detail)
  end

  # def update_withdraw_detail(withdraw_detail, withdraw_detail_params)
  #   if withdraw_detail.update!(withdraw_detail_params)
  #     CommonService.response_format(ResponseCode.COMMON.OK, withdraw_detail)
  #   else
  #     ResponseCode.COMMON.FAILED['message'] = withdraw_detail.errors
  #     CommonService.response_format(ResponseCode.COMMON.FAILED)
  #   end
  # end

  def destory_withdraw_detail(withdraw_detail)
    withdraw_detail.destroy
    CommonService.response_format(ResponseCode.COMMON.OK)
  end

end