#
# Cookbook Name:: gitosis
# Recipe:: install
#

# package 'UNKNOWN/gitosis' do
#   version node[:gitosis_version]
#   action :install
# end

execute "checkout /home/git/gitosis" do
  cwd "/home/git"
  user "git"
  group "git"
  command "git clone git://eagain.net/gitosis.git"
  not_if { File.directory?("/home/git/gitosis") }
end

execute "sync /home/git/gitosis" do
  cwd "/home/git/gitosis"
  user "git"
  group "git"
  command "git pull origin master"
  not_if { File.exist?("/home/git/.gitosis.conf") }
end

execute "install-gitosis" do
  cwd "/home/git/gitosis"
  command "python setup.py install"
  not_if { File.executable?("/usr/bin/gitosis-serve") }
end

update_file "/tmp/pubkey.txt" do
  owner "git"
  group "git"
  mode 0644
  body node[:user_ssh_key][0]
end

directory "/home/git/repositories" do
  owner "git"
  group "git"
  mode 0755
end

execute "clone-gitosis-admin" do
  cwd "/home/git/repositories/"
  user "git"
  group "git"
  command "git clone --bare git://github.com/jruby/gitosis-admin.git"
  not_if { File.directory?("/home/git/repositories/gitosis-admin.git") }
end

execute "initialize-gitosis" do
  command "sudo -H -u git gitosis-init < /tmp/pubkey.txt"
  not_if { File.exist?("/home/git/.gitosis.conf") }
end

file "/home/git/repositories/gitosis-admin.git/hooks/post-update" do
  mode "0755"
end

file "/tmp/pubkey.txt" do
  action :delete
end
