class CommonService < BaseService
  def self.response_format(response_code, data=nil)
    response = response_code.as_json
    data.nil? ? response : response[:data] = data
    response
  end

  def self.import_products(file_path="/var/www/eshop/test.csv")
    CSV.foreach(file_path) do |row|
      # use row here...
      puts row
    end
  end
end