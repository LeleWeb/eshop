class CommonService < BaseService
  def self.response_format(response_code, message=nil, data=nil)
    data.nil? ? response_code : response_code['data'] = data
    response_code
  end
end