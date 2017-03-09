class BaseService < Logger
  def initializer
    logger = File.open("#{Rails.root}/log/eshop.log", 'a')
    logger.sync = true
    LOG = BaseService.new(logger)
  end

  def format_message(severity, timestamp, progname, msg)
    "#{timestamp.to_formatted_s(:db)} #{severity} #{msg}\n"
  end
  
end