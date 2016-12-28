# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# 账户种子数据
# account = Account.create({
#                             mobile_number: '13758949777',
#                             email: '3407586904@qq.com'
#                         })
# account = Account.first
#
# # 账户角色种子数据
# roles = Role.create([
#                         {
#                             name: 'customer',
#                             remark: '消费者角色'
#                         },
#                         {
#                             name: 'store',
#                             remark: '商家角色'
#                         },
#                         {
#                             name: 'administrator',
#                             remark: '系统管理员角色'
#                         }
#                     ])
#
# # 账户角色设置
# AccountsRole.create(account_id: account.id, role_id: Role.find_by(name: 'store').id)
#
# # 创建商家
# store = account.create_store(name: "环球捕手",
#                              description: "微商城",
#                              # type: 1,
#                              address: "杭州",
#                              mobile_number: "13758949777")

# 分销规则种子数据
store = Store.find_by(name: "环球捕手")
store.distribution_rules.create(name: "ANYONE", category: Settings.DISTRIBUTION_RULES.ANYONE)