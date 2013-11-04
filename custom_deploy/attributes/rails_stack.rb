default[:opsworks][:custom_rails_stack][:name] = "nginx_passenger"
case node[:opsworks][:custom_rails_stack][:name]
when "apache_passenger"
  default[:opsworks][:custom_rails_stack][:recipe] = "passenger_apache2::rails"
  default[:opsworks][:custom_rails_stack][:needs_reload] = true
  default[:opsworks][:custom_rails_stack][:service] = 'apache2'
  default[:opsworks][:custom_rails_stack][:restart_command] = 'touch tmp/restart.txt'
when "nginx_unicorn"
  default[:opsworks][:custom_rails_stack][:recipe] = "unicorn::rails"
  default[:opsworks][:custom_rails_stack][:needs_reload] = true
  default[:opsworks][:custom_rails_stack][:service] = 'unicorn'
  default[:opsworks][:custom_rails_stack][:restart_command] = '../../shared/scripts/unicorn clean-restart'
when "nginx_passenger"
  default[:opsworks][:custom_rails_stack][:recipe] = ""
  default[:opsworks][:custom_rails_stack][:needs_reload] = true
  default[:opsworks][:custom_rails_stack][:service] = 'nginx'
  default[:opsworks][:custom_rails_stack][:restart_command] = 'touch tmp/restart.txt'
else
  raise "Unknown stack: #{node[:opsworks][:custom_rails_stack][:name].inspect}"
end
