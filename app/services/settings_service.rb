class SettingsService < BaseService
  def get_settings(query_params)
    LOG.info %Q{#{__FILE__},#{__LINE__},#{__method__},params:
                                                        store: #{store.inspect},
                                                        query_params: #{query_params.inspect} }

    # 是否按照查询类型检索
    if query_params["type"] == "home"
      return SettingsService.get_home_settings(store, query_params["customer"])
    end

    products = store.products.where(is_deleted: false)
    total_count = nil

    # 按照产品分类检索
    if !query_params[:category].blank?
      products = eval(products.blank? ? "Product" : "products").where(category_id: query_params[:category])
    end

    # 按照产品属性检索
    if !query_params[:property].blank?
      products = eval(products.blank? ? "Product" : "products").where(property: query_params[:property])
    end

    # 如果存在分页参数,按照分页返回结果.
    if !query_params[:page].blank? && !query_params[:per_page].blank?
      products = eval(products.blank? ? "Product" : "products").
                      page(query_params[:page]).
                      per(query_params[:per_page])
      total_count = products.total_count
    else
      total_count = products.size
    end

    CommonService.response_format(ResponseCode.COMMON.OK, SettingsService.get_settings(products, total_count))
    # if !query_params[:category].blank? && !query_params[:limit].blank?
    #   CommonService.response_format(ResponseCode.COMMON.OK,
    #                                 self.find_by_category(store, query_params))
    # elsif !query_params[:search].blank?
    #   CommonService.response_format(ResponseCode.COMMON.OK,
    #                                 self.find_by_search(store, query_params))
    # else
    #   CommonService.response_format(ResponseCode.COMMON.OK, SettingsService.find_setting_datas(store))
    # end
  end

  def self.get_setting(setting)
    LOG.info %Q{#{__FILE__},#{__LINE__},#{__method__},params:
                                                        setting: #{setting.inspect}  }
    setting.as_json.merge("products" => setting.products)
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

      CommonService.response_format(ResponseCode.COMMON.OK,
                                    SettingsService.get_settings(Setting.where(setting_type: Settings.SETTING.HOME_PRODUCT)))
    rescue Exception => e
      # TODO 打印LOG
      LOG.error "Error: file: #{__FILE__} line:#{__LINE__} 创建设置失败! Details: #{e.message}"

      return CommonService.response_format(ResponseCode.COMMON.FAILED,
                                           "Error: file: #{__FILE__} line:#{__LINE__} 创建设置失败! Details: #{e.message}")
    end
  end

  def update_setting(setting, setting_params)
    LOG.info %Q{#{__FILE__},#{__LINE__},#{__method__},params:
                                                        setting: #{setting.inspect},
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
              if !item["products"].empty?
                begin
                  setting.products.where(position: item["category"]).map{|x| x.delete}
                rescue Exception => e
                  # TODO 删除已设置的首页分类商品失败，打印对应LOG
                  LOG.error "Error: file: #{__FILE__} line:#{__LINE__} destroy setting products failed! Details: #{e.message}"

                  # 继续向上层抛出异常
                  raise e
                end

                setting.products << Product.find(item["products"])
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

      CommonService.response_format(ResponseCode.COMMON.OK,
                                    SettingsService.get_settings(Setting.where(setting_type: Settings.SETTING.HOME_PRODUCT)))
    rescue Exception => e
      # TODO 打印LOG
      LOG.error "Error: file: #{__FILE__} line:#{__LINE__} 更新设置失败! Details: #{e.message}"

      return CommonService.response_format(ResponseCode.COMMON.FAILED,
                                           "Error: file: #{__FILE__} line:#{__LINE__} 更新设置失败! Details: #{e.message}")
    end
  end

  def destroy_setting(product, destroy_params)
    LOG.info %Q{#{__FILE__},#{__LINE__},#{__method__},params:
                                                        product: #{product.inspect},
                                                        destroy_params: #{destroy_params.inspect} }

    begin
      Product.transaction do
        # 删除商品本身
        begin
          product.update!(is_deleted: true, deleted_at: Time.now)
        rescue Exception => e
          # TODO 删除商品失败，打印对应LOG
          LOG.error "Error: file: #{__FILE__} line:#{__LINE__} destroy product failed! Details: #{e.message}"

          # 继续向上层抛出异常
          raise e
        end

        # 删除产品价格
        begin
          product.prices.each {|price| price.update!(is_deleted: true, deleted_at: Time.now)}
        rescue Exception => e
          # TODO 删除产品价格失败，打印对应LOG
          LOG.error "Error: file: #{__FILE__} line:#{__LINE__} destroy product prices failed! Details: #{e.message}"

          # 继续向上层抛出异常
          raise e
        end

        # 删除产品计算策略
        begin
          product.compute_strategies.each {|compute_strategy| compute_strategy.update!(is_deleted: true, deleted_at: Time.now)}
        rescue Exception => e
          # TODO 删除产品计算策略失败，打印对应LOG
          LOG.error "Error: file: #{__FILE__} line:#{__LINE__} destroy product compute strategies failed! Details: #{e.message}"

          # 继续向上层抛出异常
          raise e
        end

        # 删除产品团购数据
        begin
          product.group_buying.update!(is_deleted: true, deleted_at: Time.now)
        rescue Exception => e
          # TODO 删除产品团购数据失败，打印对应LOG
          LOG.error "Error: file: #{__FILE__} line:#{__LINE__} destroy product group buying failed! Details: #{e.message}"

          # 继续向上层抛出异常
          raise e
        end

        # 批量删除
        begin
          if !destroy_params.blank?
            destroy_params.each do |setting_id|
              Product.find(setting_id).update!(is_deleted: true, deleted_at: Time.now)
            end
          end
        rescue Exception => e
          # TODO 批量删除商品失败，打印对应LOG
          LOG.error "Error: file: #{__FILE__} line:#{__LINE__} destroy mutli product failed! Details: #{e.message}"

          # 继续向上层抛出异常
          raise e
        end

      end
    rescue Exception => e
      # TODO 打印LOG
      LOG.error "Error: file: #{__FILE__} line:#{__LINE__} 删除商品失败! Details: #{e.message}"

      return CommonService.response_format(ResponseCode.COMMON.FAILED,
                                           "Error: file: #{__FILE__} line:#{__LINE__} 删除商品失败! Details: #{e.message}")
    end

    CommonService.response_format(ResponseCode.COMMON.OK)
  end

  def self.get_settings(settings)
    settings.map{|setting| self.get_setting(setting)}
  end

  def self.get_setting(setting)
    setting.as_json.merge("products" => ProductsService.get_products_no_count(setting.products))
  end

end
