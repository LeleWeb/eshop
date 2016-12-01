# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# 账户种子数据
accounts = Account.create([
                        {
                            mobile_number: '18161803190',
                            email: '719048757@qq.com'
                        },
                        {
                            mobile_number: '18717373045',
                            email: '514079588@qq.com'
                        },
                        {
                            mobile_number: '18629365871',
                            email: '344410812@qq.com'
                        }
                    ])

# 账户角色种子数据
roles = Role.create([
                        {
                            name: 'customer',
                            remark: '消费者角色'
                        },
                        {
                            name: 'store',
                            remark: '商家角色'
                        },
                        {
                            name: 'administrator',
                            remark: '系统管理员角色'
                        }
                    ])

# 账户角色设置
accounts.each do |account|
  AccountsRole.create(account_id: account.id, role_id: Role.find_by(name: 'customer').id)
  AccountsRole.create(account_id: account.id, role_id: Role.find_by(name: 'store').id)
  AccountsRole.create(account_id: account.id, role_id: Role.find_by(name: 'administrator').id)
end

account = accounts.first

# 创建消费者
customer = account.create_customer(mobile_number: "18161803190",
                        nick_name: "bluesky",
                        real_name: "张伟",
                        gender: "男",
                        age: 30,
                        address: "西安市高新区",
                        is_wechat_focus: true,
                        level: 0,
                        integral: 0)

# 创建商家
store = account.create_store(name: "环球捕手",
                     description: "微商城",
                     type: 1,
                     address: "西安高新",
                     mobile_number: "18112345678")

# 创建产品
product = store.products.create([{name: "小米4",
                                   description: "屌丝神器",
                                   detail: "商品详情",
                                   stock: 100,
                                   price: 1999.0,
                                   real_price: 999.12,
                                   state: 0}
                                 ])

# 产品详情项
detail_items = DetailItem.create([
                                     { name: "品牌" },
                                     { name: "尺寸" }
                                ])

# 创建产品详情
product.product_details.create([
                                   { detail_item_id: detail_items[0].id, content: "小米"},
                                   { detail_item_id: detail_items[1].id, content: "5.5寸"}
                               ])

# 图片资源

# 订单
store.orders.create(product_id: product.id,
                    unit_price: product.price,
                    amount: 10,
                    status: 0,
                    total_price: 19990.0,
                    seller_id: store.id,
                    seller_type: "Store",
                    estimate: 0)

customer.orders.create(product_id: product.id,
                      unit_price: product.price,
                      amount: 10,
                      status: 0,
                      total_price: 19990.0,
                      seller_id: store.id,
                      seller_type: "Store",
                      estimate: 0)

# 购物车
customer.shopping_carts.create(product_id: product.id,
                               amount: 10)