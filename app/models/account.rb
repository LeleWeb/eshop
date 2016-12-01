class Account < ApplicationRecord
  has_secure_password

  has_and_belongs_to_many :roles

  before_create :generate_authentication_token

  def generate_authentication_token
    loop do
      self.authentication_token = SecureRandom.base64(64)
      break if !Account.find_by(authentication_token: authentication_token)
    end
  end

  def reset_auth_token!
    generate_authentication_token
    save
  end

  def destory_auth_token!
    self.authentication_token = ''
    self.save
  end

end
