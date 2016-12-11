require 'net/http'

class HttpService < BaseService
  def get(url)
    uri = URI('http://example.com/some_path?query=string')

    Net::HTTP.start(uri.host, uri.port) do |http|
      request = Net::HTTP::Get.new uri

      response = http.request request # Net::HTTPResponse object
    end
  end

  def post(url, params)
    uri = URI(url)
    req = Net::HTTP::Post.new(uri)
    req.set_form_data(params)

    res = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req)
    end

    case res
      when Net::HTTPSuccess, Net::HTTPRedirection
        # OK
        puts res.body
      else
        res.value
    end
  end

end