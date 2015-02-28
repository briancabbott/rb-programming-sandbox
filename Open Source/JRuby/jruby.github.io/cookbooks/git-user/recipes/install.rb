#
# Cookbook Name:: git-user
# Recipe:: install
#

require 'etc'

user_obj = {
  :gid => Etc.getgrnam("deploy").gid + 1,
  :username => 'git',
  :uid => Etc.getpwnam("deploy").uid + 1,
  :comment => "Git repository user"
}

execute "create-group" do
  command "groupadd -g #{user_obj[:gid]} #{user_obj[:username]}"
  not_if "getent group #{user_obj[:gid]}"
end

user "create-user" do
  username user_obj[:username]
  uid user_obj[:uid]
  gid user_obj[:gid].to_i if user_obj[:gid]
  shell "/bin/bash"
  comment user_obj[:comment]
  supports :manage_home => false

  not_if "getent passwd #{user_obj[:uid]}"
end

execute "update-username" do
  command "usermod -l #{user_obj[:username]} --home /home/#{user_obj[:username]} --move-home `getent passwd #{user_obj[:uid]} | cut -d \":\" -f 1` && groupmod --new-name #{user_obj[:username]} `getent group #{user_obj[:uid]} | cut -d \":\" -f 1`"
  only_if do user_obj[:username] != `getent passwd #{user_obj[:uid]} | cut -d \":\" -f 1`  end
end

directory "/data/homedirs/#{user_obj[:username]}" do
  owner user_obj[:uid]
  group user_obj[:gid]
  mode 0755
  recursive true
end

link "/home/#{user_obj[:username]}" do
  to "/data/homedirs/#{user_obj[:username]}"
end

execute "add base dotfiles" do
  command "rsync -aq /etc/skel/ /home/#{user_obj[:username]}"
  not_if { File.exists? "/home/#{user_obj[:username]}/.bashrc" }
end

execute "chown homedir to user" do
  command "chown -R #{user_obj[:username]}:#{user_obj[:username]} /data/homedirs/#{user_obj[:username]}"
end

directory "/home/git/.ssh" do
  owner user_obj[:uid]
  group user_obj[:gid]
  mode 0700
end

execute 'add-github-to-ssh-known-hosts' do
  known_hosts = "/home/git/.ssh/known_hosts"
  not_if { File.exists?(known_hosts) && IO.readlines(known_hosts).detect {|l| l =~ /github.com/} }
  command "ssh-keyscan -t rsa,dsa github.com >> #{known_hosts}"
end

execute "generate-id-rsa" do
  user "git"
  group "git"
  command "ssh-keygen -q -t rsa -f /home/git/.ssh/id_rsa -N ''"
  not_if { File.exist?("/home/git/.ssh/id_rsa") }
end
