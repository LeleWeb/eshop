class CommonService < BaseService
  def self.response_format(response_code, data)
    response_code['data'] = data
    response_code
  end
end