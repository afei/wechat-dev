#!/usr/bin/env puma

# rails environment
environment 'production'
threads 0, 16
workers 2

# application name, application path
app_name = "wechat"
# application_path = "/var/www/wechat-dev"
application_path = "/Users/ichr/Rails/wechat-dev"
directory "#{application_path}"

# puma configration
pidfile "#{application_path}/tmp/puma.pid"
state_path "#{application_path}/tmp/puma.state"
stdout_redirect "#{application_path}/log/puma.stdout.log", "#{application_path}/log/puma.stderr.log"
bind "unix://#{application_path}/tmp/#{app_name}.sock"
activate_control_app "unix://#{application_path}/tmp/pumactl.sock"

# run as daemonize
daemonize true
on_restart do
  puts 'On restart...'
end

preload_app!

rackup DefaultRackup
port ENV['PORT'] || 3000
environment ENV['RACK_ENV'] || 'production'

on_worker_boot do
  ActiveRecord::Base.establish_connection
end
