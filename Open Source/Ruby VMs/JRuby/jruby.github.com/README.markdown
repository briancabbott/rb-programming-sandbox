This repository contains the content for http://www.jruby.org/ as
[Jekyll][]-generated site.

# Building

The site is generated with Jekyll, and while you can use the regular
`jekyll` executable, the preferred steps are the following:

1. (One time only) Install Bundler (`gem install bundler`) and run
   `bundle install` once.
1a. (env) export LANG="en_US.UTF-8"
1b. (env) export LC_ALL="en_US.UTF-8"
2. Run rake to see the available tasks:

        JRuby.org documentation site. Available tasks:
        rake clean     # Clean the site
        rake deploy    # Deploy the files to jruby.org
        rake generate  # Generate the site using Jekyll
        rake server    # Run a file server that serves and regenerates the files

3. `rake server` runs a server with a small Rack shim that emulates
   the web server configuration on jruby.org, so you can browse the site.
   It also emulates Jekyll's `--auto` mode so that files are refreshed
   as you save changes to them.

# Contributing

If you wish to contribute content updates for jruby.org, please fork,
make changes, and send pull requests or submit documentation bugs to
[JRuby's bug tracker][JIRA]. The bugs can either reference commits in
a fork on Github or attach patches.

We can't guarantee that we'll accept and deploy all patches, so please
consult with the JRuby team before making large changes. Thanks!

[Jekyll]: http://wiki.github.com/mojombo/jekyll
[JIRA]: http://jira.codehaus.org/browse/JRUBY

# TODO

Clear content under Creative Commons and publish a license for the
content as such.
