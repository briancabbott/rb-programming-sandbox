# Copyright (c) 2014 Oracle and/or its affiliates. All rights reserved. This
# code is released under a tri EPL/GPL/LGPL license. You can use it,
# redistribute it and/or modify it under the terms of the:
# 
# Eclipse Public License version 1.0
# GNU General Public License version 2
# GNU Lesser General Public License version 2.1

require "little-function"
require "mock-logger"

if defined? NATIVE
  require "psd_native/psd_native"
else
  require "psd/util"
end

module MockUtil
  if defined? NATIVE
    puts "native"
    extend PSDNative::Util
  else
    puts "ruby"
    extend PSD::Util
  end
end

def value
  14
end

def iterations
  50_000_000
end

def function(value)
  MockUtil::clamp(value, 10, 20)
end

def expected
  14
end
