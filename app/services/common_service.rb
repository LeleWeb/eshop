class CommonService < BaseService
  def self.response_format(response_code, data=nil)
    p response_code
    p data
    debug
    data.nil? ? response_code : response_code['data'] = data
    response_code
  end
end