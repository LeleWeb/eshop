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
account.create_customer(mobile_number: "18161803190",
                        nick_name: "bluesky",
                        real_name: "张伟",
                        gender: "男",
                        age: 30,
                        address: "西安市高新区",
                        is_wechat_focus: true,
                        level: 0,
                        integral: 0)

# 创建商家

# 创建产品

# 创建产品详情

# 产品详情项

# 图片资源

# 订单

# 购物车
