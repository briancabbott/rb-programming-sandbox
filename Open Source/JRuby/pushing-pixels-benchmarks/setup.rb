# Copyright (c) 2014 Oracle and/or its affiliates. All rights reserved. This
# code is released under a tri EPL/GPL/LGPL license. You can use it,
# redistribute it and/or modify it under the terms of the:
# 
# Eclipse Public License version 1.0
# GNU General Public License version 2
# GNU Lesser General Public License version 2.1

require_relative "config"

REQUIRED_FILES = [
  "~/.rbenv/versions/2.1.2/bin/ruby",
  "~/.rbenv/versions/2.1.2/bin/bundle",
  "~/.rbenv/versions/rbx-2.2.10/bin/ruby",
  "~/.rbenv/versions/rbx-2.2.10/bin/bundle",
  "~/.rbenv/versions/topaz-dev/bin/ruby",
  "~/.rbenv/versions/jruby-1.7.13/bin/ruby",
  "../graalvm-jdk1.8.0/bin/java",
  "../jruby/bin/jruby"
]

error = false

REQUIRED_FILES.each do |file|
  unless File.exist? File.expand_path(file)
    puts "#{file} doesn't exist - you need to set this up yourself - check the readme"
    error = true
  end
end

exit if error

GIT_PULLS = [
  ["chunky_png",      "efd61c8d0ddcabdcf09fb44f8e8c1ba709995940", "https://github.com/wvanbergen/chunky_png.git"],
  ["oily_png_mri",    "705202d54c891c709a2c9075e6d0cd4bba04f209", "https://github.com/wvanbergen/oily_png.git"],
  ["oily_png_rbx",    "705202d54c891c709a2c9075e6d0cd4bba04f209", "https://github.com/wvanbergen/oily_png.git"],
  ["psd.rb",          "e14d652ddc705e865d8b2b897d618b25d78bcc7c", "https://github.com/layervault/psd.rb.git"],
  ["psd_native_mri",  "bbea04db2f4f483bde73b6793e68eff73f3b9c3f", "https://github.com/layervault/psd_native.git"],
  ["psd_native_rbx",  "bbea04db2f4f483bde73b6793e68eff73f3b9c3f", "https://github.com/layervault/psd_native.git"],
  ["perfer",          "98c4b23aa1884b3bbc45cde377c3d9c2f6260f6a", "https://github.com/jruby/perfer.git"]
]

GIT_PULLS.each do |name, commit, origin|
  unless Dir.exist? name
    `git clone #{origin} #{name} 2>&1 && cd #{name} && git checkout #{commit} 2>&1`
    
    unless Dir.exist? name
      puts "couldn't get #{origin}, try cloning it into #{name} at commit #{commit} yourself and see what's going wrong"
      error = true
    end
  end
end

exit if error

COMPILES = [
  ["cd oily_png_mri && ~/.rbenv/versions/2.1.2/bin/bundle install && ~/.rbenv/versions/2.1.2/bin/rake 2>&1", Proc.new { File.exist?("oily_png_mri/lib/oily_png/oily_png.bundle") || File.exist?("oily_png_mri/lib/oily_png/oily_png.so") }],
  ["cd oily_png_rbx && ~/.rbenv/versions/rbx-2.2.10/bin/bundle install && ~/.rbenv/versions/rbx-2.2.10/bin/rake 2>&1", Proc.new { File.exist?("oily_png_rbx/lib/oily_png/oily_png.bundle") || File.exist?("oily_png_rbx/lib/oily_png/oily_png.so") }],
  ["cd psd_native_mri && ~/.rbenv/versions/2.1.2/bin/bundle install && ~/.rbenv/versions/2.1.2/bin/rake 2>&1", Proc.new { File.exist?("psd_native_mri/lib/psd_native/psd_native.bundle") || File.exist?("psd_native_mri/lib/psd_native/psd_native.so") }],
  ["cd psd_native_rbx && ~/.rbenv/versions/rbx-2.2.10/bin/bundle install && ~/.rbenv/versions/rbx-2.2.10/bin/rake 2>&1", Proc.new { File.exist?("psd_native_rbx/lib/psd_native/psd_native.bundle") || File.exist?("psd_native_rbx/lib/psd_native/psd_native.so") }],
]

COMPILES.each do |command, test|
  unless test.call
    `#{command}`
    
    unless test.call
      puts "couldn't run compile script: #{command}, try it yourself and see what's going wrong"
      error = true
    end
  end
end

exit if error

puts "Should be good to go..."
