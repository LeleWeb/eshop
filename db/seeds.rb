# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

accounts = Account.create([
                        {
                            mobile_number: '18161803333',
                            email: '111@qq.com'
                        },
                        {
                            mobile_number: '18161801111',
                            email: '111@qq.com'
                        }
                    ])