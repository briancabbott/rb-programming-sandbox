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
  require "psd/color"
  require "psd/util"
end

def value
  196
end

def iterations
  5_000_000
end

if defined? NATIVE
  puts "native"
  def cmyk_to_rgb(c, m, y, k)
    PSDNative::Color::cmyk_to_rgb(c, m, y, k)
  end
else
  puts "ruby"
  def cmyk_to_rgb(c, m, y, k)
    PSD::Color::cmyk_to_rgb(c, m, y, k)
  end
end

def function(value)
  rgb = cmyk_to_rgb(value, value, value, value)
  rgb[:r] + rgb[:g] + rgb[:b]
end

def expected
  42
end
