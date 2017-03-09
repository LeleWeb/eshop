worker_logfile = File.open("#{Rails.root}/log/production.log", 'a')
worker_logfile.sync = true
LOG = WorkerLogger.new(worker_logfile)