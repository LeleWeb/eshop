class ResponseCode < Settingslogic
  source "#{Rails.root}/config/response_code.yml"
  namespace Rails.env
end