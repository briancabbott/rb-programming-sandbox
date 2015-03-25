#
# Cookbook Name:: git-daemon
# Recipe:: install
#

remote_file "/etc/conf.d/git-daemon" do
  source "git-daemon.conf"
end

service "git-daemon" do
  action :start
  supports :restart => false, :status => false
end
