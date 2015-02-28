
service "sshd" do
  action :nothing
  supports :restart => true
end

Dir['/data/etc/ssh/*'].each do |sshf|
  execute "preserve ssh host keys" do
    command "cp -p #{sshf} /etc/ssh"
    notifies :restart, resources(:service => "sshd"), :delayed
    not_if { system "cmp #{sshf} /etc/ssh/#{File.basename(sshf)} > /dev/null"; $?.success? }
  end
end

require_recipe 'nginx_config'

require_recipe 'git-user'

require_recipe 'gitosis'

require_recipe 'repositories'

require_recipe 'git-daemon'
