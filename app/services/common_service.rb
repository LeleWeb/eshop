class CommonService < BaseService
  def self.response_format(response_code, data=nil)
    response = response_code.dump
    p response_code
    p data
    byebug
    data.nil? ? response : response[:data] = data
    response
  end
end