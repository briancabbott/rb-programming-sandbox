# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'arjdbc/version'

Gem::Specification.new do |gem|
  gem.name = 'activerecord-jdbc-adapter'
  gem.version = ArJdbc::VERSION
  gem.platform = Gem::Platform::RUBY
  gem.authors = ['Nick Sieger', 'Ola Bini', 'Karol Bucek', 'JRuby contributors']
  gem.email = ['nick@nicksieger.com', 'ola.bini@gmail.com', 'self@kares.org']
  gem.homepage = 'https://github.com/jruby/activerecord-jdbc-adapter'
  gem.license = "BSD"
  gem.summary = 'JDBC adapter for ActiveRecord, for use within JRuby on Rails.'
  gem.description = "" <<
    "AR-JDBC is a database adapter for Rails' ActiveRecord component designed " <<
    "to be used with JRuby built upon Java's JDBC API for database access. " <<
    "Provides (ActiveRecord) built-in adapters: MySQL, PostgreSQL and SQLite3 " <<
    "as well as adapters for popular databases such as Oracle, SQLServer, " <<
    "DB2, FireBird and even Java (embed) databases: Derby, HSQLDB and H2. " <<
    "It allows to connect to virtually any JDBC-compliant database with your " <<
    "JRuby on Rails application."

  gem.require_paths = ["lib"]

  gem.files = `git ls-files`.split("\n").
    reject { |f| f =~ /^(activerecord-jdbc[^-]|jdbc-)/ }. # gem directories
    reject { |f| f =~ /^(bench|test)/ }. # not sure if including tests is useful
    reject { |f| f =~ /^(gemfiles)/ } # no tests - no Gemfile_s appraised ...
  gem.test_files = gem.files.grep /^test\//

  if ENV['RELEASE'] == 'true'
    gem.files << 'lib/arjdbc/jdbc/adapter_java.jar' # no longer in git since 1.4
  else
    gem.extensions << 'Rakefile' # to support auto-building .jar with :git paths
    # compilation .jar dependencies for extension (at least until `mvn') :
    gem.add_development_dependency 'jdbc-mysql'
    gem.add_development_dependency 'jdbc-postgres'
  end

  #gem.add_dependency 'activerecord', '>= 2.2'

  gem.add_development_dependency 'rake', '~> 10.3.2'

  #gem.add_development_dependency 'test-unit', '~> 2.5.4'
  #gem.add_development_dependency 'test-unit-context', '>= 0.4.0'
  #gem.add_development_dependency 'mocha', '~> 0.13.1'

  #gem.rdoc_options = ["--main", "README.md", "-SHN", "-f", "darkfish"]

end

