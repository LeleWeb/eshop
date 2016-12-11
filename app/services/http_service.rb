require 'net/http'

class HttpService < BaseService
  def self.get(url, query_params=nil)
    uri = URI(url)

    if !query_params.blank?
      uri.query = URI.encode_www_form(params)
    end

    res = Net::HTTP.get_response(uri)
    res.is_a?(Net::HTTPSuccess) ? res.body : res.value
  end

  def self.post(url, params)
    uri = URI(url)
    req = Net::HTTP::Post.new(uri)
    req.set_form_data(params)

    res = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req)
    end

    case res
      when Net::HTTPSuccess, Net::HTTPRedirection
        res.body
      else
        res.value
    end
  end

end