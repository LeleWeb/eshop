require 'parseexcel'

class CommonService < BaseService
  def self.response_format(response_code, data=nil)
    response = response_code.as_json
    data.nil? ? response : response[:data] = data
    response
  end

  def self.import_products(file_path="/var/www/eshop/products.xlsx")
    workbook = Spreadsheet::ParseExcel.parse(file_path)
    products_sheet = workbook.worksheet(0)
    worksheet.each(skip) do |row|
      puts row
    end
  end
end