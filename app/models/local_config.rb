class LocalConfig < Settingslogic
  source "#{Rails.root}/config/local_config.yml"
  namespace Rails.env
end