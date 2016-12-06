class CommonService < BaseService
  def self.response_format(response_code, data=nil)
    response = response_code.as_json
    data.nil? ? response : response[:data] = data
    response
  end
end