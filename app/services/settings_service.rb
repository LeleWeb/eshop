class SettingsService < BaseService
  def get_settings(query_params)
    LOG.info %Q{#{__FILE__},#{__LINE__},#{__method__},params:
                                                        query_params: #{query_params.inspect} }

    CommonService.response_format(ResponseCode.COMMON.OK, SettingsService.get_home_product)
  end

  def create_setting(setting_params)
    LOG.info %Q{#{__FILE__},#{__LINE__},#{__method__},params:
                                                             setting_params: #{setting_params.inspect} }

    setting = nil

    begin
      # 解析参数
      begin
        data = setting_params.extract!("data")["data"]
      rescue Exception => e
        # TODO 解析参数失败，打印对应LOG
        LOG.error "Error: file: #{__FILE__} line:#{__LINE__} params invalid! Details: #{e.message}"

        # 继续向上层抛出异常
        raise e
      end

      Product.transaction do
        # 设置与商品建立关联
        begin
          if !data.blank?
            data.each do |item|
              # 创建设置
              begin
                setting = Setting.create!(setting_params.merge(position: item["category"]))
              rescue Exception => e
                # TODO 创建设置失败，打印对应LOG
                LOG.error "Error: file: #{__FILE__} line:#{__LINE__} create setting failed! Details: #{e.message}"

                # 继续向上层抛出异常
                raise e
              end

              setting.products << Product.find(item["products"])
            end
          end
        rescue Exception => e
          # TODO 设置与商品建立关联失败，打印对应log
          puts "Error: file: #{__FILE__} line:#{__LINE__} create setting and product relation failed! Details: #{e.message}"

          # 继续向上层抛出异常
          raise e
        end

      end

      CommonService.response_format(ResponseCode.COMMON.OK, SettingsService.get_home_product)
    rescue Exception => e
      # TODO 打印LOG
      LOG.error "Error: file: #{__FILE__} line:#{__LINE__} 创建设置失败! Details: #{e.message}"

      return CommonService.response_format(ResponseCode.COMMON.FAILED,
                                           "Error: file: #{__FILE__} line:#{__LINE__} 创建设置失败! Details: #{e.message}")
    end
  end

  def update_setting(setting_params)
    LOG.info %Q{#{__FILE__},#{__LINE__},#{__method__},params:
                                                        setting_params: #{setting_params.inspect} }

    begin
      # 解析参数
      begin
        data = setting_params.extract!("data")["data"]
      rescue Exception => e
        # TODO 解析参数失败，打印对应LOG
        LOG.error "Error: file: #{__FILE__} line:#{__LINE__} params invalid! Details: #{e.message}"

        # 继续向上层抛出异常
        raise e
      end

      Product.transaction do
        # 设置与商品建立关联
        begin
          if !data.blank?
            data.each do |item|
              if item.key?("products") && !item["products"].empty?
                begin
                  setting = Setting.find_by(setting_type: Settings.SETTING.HOME_PRODUCT.VALUE, position: item["category"])
                  setting.products.clear
                  setting.products << Product.find(item["products"])
                rescue Exception => e
                  # TODO 删除已设置的首页分类商品失败，打印对应LOG
                  LOG.error "Error: file: #{__FILE__} line:#{__LINE__} destroy setting products failed! Details: #{e.message}"

                  # 继续向上层抛出异常
                  raise e
                end
              end
            end
          end
        rescue Exception => e
          # TODO 设置与商品建立关联失败，打印对应log
          puts "Error: file: #{__FILE__} line:#{__LINE__} update setting and product relation failed! Details: #{e.message}"

          # 继续向上层抛出异常
          raise e
        end
      end

      CommonService.response_format(ResponseCode.COMMON.OK, SettingsService.get_home_product)
    rescue Exception => e
      # TODO 打印LOG
      LOG.error "Error: file: #{__FILE__} line:#{__LINE__} 更新设置失败! Details: #{e.message}"

      return CommonService.response_format(ResponseCode.COMMON.FAILED,
                                           "Error: file: #{__FILE__} line:#{__LINE__} 更新设置失败! Details: #{e.message}")
    end
  end

  def destroy_setting(setting, destroy_params)
    LOG.info %Q{#{__FILE__},#{__LINE__},#{__method__},params:
                                                        setting: #{setting.inspect},
                                                        destroy_params: #{destroy_params.inspect} }

    begin
      Product.transaction do
        # 删除设置本身
        begin
          Setting.where(setting_type: Settings.SETTING.HOME_PRODUCT).map{|x| x.update!(is_deleted: true, deleted_at: Time.now) }
        rescue Exception => e
          # TODO 删除商品失败，打印对应LOG
          LOG.error "Error: file: #{__FILE__} line:#{__LINE__} destroy settings failed! Details: #{e.message}"

          # 继续向上层抛出异常
          raise e
        end
      end

      CommonService.response_format(ResponseCode.COMMON.OK)
    rescue Exception => e
      # TODO 打印LOG
      LOG.error "Error: file: #{__FILE__} line:#{__LINE__} 删除首页商品设置失败! Details: #{e.message}"

      return CommonService.response_format(ResponseCode.COMMON.FAILED,
                                           "Error: file: #{__FILE__} line:#{__LINE__} 删除首页商品设置失败! Details: #{e.message}")
    end
  end

  def self.get_settings(settings)
    settings.map{|setting| self.get_setting(setting)}
  end

  def self.get_setting(setting)
    setting.as_json.merge("products" => ProductsService.get_products_no_count(setting.products))
  end

  # 获取首页商品设置
  def self.get_home_product
    SettingsService.get_settings(Setting.where(setting_type: Settings.SETTING.HOME_PRODUCT, is_deleted: false))
  end

end
