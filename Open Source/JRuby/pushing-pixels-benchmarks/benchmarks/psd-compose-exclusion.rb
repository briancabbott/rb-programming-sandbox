# Copyright (c) 2014 Oracle and/or its affiliates. All rights reserved. This
# code is released under a tri EPL/GPL/LGPL license. You can use it,
# redistribute it and/or modify it under the terms of the:
# 
# Eclipse Public License version 1.0
# GNU General Public License version 2
# GNU Lesser General Public License version 2.1

require "little-function"
require "mock-logger"

require "psd/renderer/compose"

if defined? NATIVE
  require "psd_native/psd_native"
else
  require "chunky_png/color"
  require "psd/renderer/compose"
end

def value
  0x11223344
end

def iterations
  1_000_000
end

if defined? NATIVE
  puts "native"
  def function(value)
    PSDNative::Compose::exclusion(value, value, PSD::Compose::DEFAULT_OPTS)
  end
else
  puts "ruby"
  def function(value)
    PSD::Compose::exclusion(value, value)
  end
end

def expected
  0x19304475
end
