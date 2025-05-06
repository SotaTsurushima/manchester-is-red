if ENV['RAILS_ENV'] == 'development'
  pidfile = File.expand_path('../tmp/pids/server.pid', __dir__)
  File.delete(pidfile) if File.exist?(pidfile)
end 