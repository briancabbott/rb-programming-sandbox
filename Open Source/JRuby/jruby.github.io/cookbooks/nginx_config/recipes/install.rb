#
# Cookbook Name:: nginx_config
# Recipe:: install
#

# package 'UNKNOWN/nginx_config' do
#   version node[:nginx_config_version]
#   action :install
# end

service "nginx" do
  action :nothing
  supports :restart => true, :status => true
end

remote_file "/data/nginx/servers/jruby.conf" do
  action :create
  source 'jruby.conf'
  owner node[:owner_name]
  group node[:owner_name]
  mode 0644
  notifies :restart, resources(:service => "nginx"), :delayed
end

cron "apidocs" do
  minute    '10'
  hour      '2'
  day       '*'
  month     '*'
  weekday   '*'
  command   'cd /data && wget --mirror http://ci.jruby.org/job/jruby-dist-release/javadoc/ > /dev/null'
  action :create
end
