#
# Cookbook Name:: repositories
# Recipe:: install
#

Repositories = {
  'jruby.org' => 'jruby.github.com'
}

Dir['/home/git/repositories/*'].each do |repo|
  name = File.basename(repo, '.git')
  Repositories[name] ||= name
end

Repositories.each_pair do |repo,remote|
  execute "#{repo}-add-github-remote" do
    cwd "/home/git/repositories/#{repo}.git"
    user "git"
    group "git"
    command "git remote add github git@github.com:jruby/#{remote}.git"
    not_if { File.exist?("/home/git/repositories/#{repo}.git/hooks/post-receive") }
  end

  update_file "/home/git/repositories/#{repo}.git/hooks/post-receive" do
    action :rewrite
    owner "git"
    group "git"
    mode 0755
    body <<-SCR
#/bin/bash

read oldrev newrev refname
git push github `basename $refname`
SCR
  end

  if repo == "jruby"
    update_file "/home/git/repositories/#{repo}.git/hooks/post-receive" do
      action :append
      owner "git"
      group "git"
      mode 0755
      body <<-SCR

echo Queueing new jruby-git build
curl -s http://ci.jruby.org/job/jruby-git/build?token=blast-off > /dev/null
SCR
    end
  end

  file "/home/git/repositories/#{repo}.git/git-daemon-export-ok" do
    owner "git"
    group "git"
    mode 0644
  end
end
