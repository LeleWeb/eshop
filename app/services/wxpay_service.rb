class WxpayService < BaseService
  def create_notify(wxpay_params)
    # 在对业务数据进行状态检查和处理之前，要采用数据锁进行并发控制，以避免函数重入造成的数据混乱。
    # TODO

    # 检查对应业务数据的状态，判断该通知是否已经处理过。
    # 此处的处理策略为：判断该笔支付对于的本系统商户订单状态是否已经为已支付
    order = Order.find_by_order_number(wxpay_params["out_trade_no"])
    if order.status == Settings.ORDER.STATUS.PAID
      # 该通知是否已经处理过，直接返回结果成功。
      return Settings.WECHAT.WXPAY_NOTIFY.RETURN_CODE.OK
    end

    # 签名验证，防止数据泄漏导致出现“假通知”，造成资金损失。
    if !WechatService.check_sign(wxpay_params)
      return
    end

    # 处理业务逻辑
    ## 1. 修改本地对应订单的状态
    order.update(status: Settings.ORDER.STATUS.PAID)

    ## 2. 保存支付结果到本地数据库
    WxpayNotification.create(wxpay_params.merge({:order => order.id}))

    #返回结果成功给微信服务器
    Settings.WECHAT.WXPAY_NOTIFY.RETURN_CODE.OK
  end

end