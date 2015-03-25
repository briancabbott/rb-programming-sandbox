# Copyright (c) 2014 Oracle and/or its affiliates. All rights reserved. This
# code is released under a tri EPL/GPL/LGPL license. You can use it,
# redistribute it and/or modify it under the terms of the:
# 
# Eclipse Public License version 1.0
# GNU General Public License version 2
# GNU Lesser General Public License version 2.1

require "little-function"

if defined? NATIVE
  require "oily_png/oily_png"
else
  require "chunky_png/color"
end

def value
  0x11223344
end

def iterations
  5_000_000
end

module MockColour
  if defined? NATIVE
    puts "native"
    extend OilyPNG::Color
  else
    puts "ruby"
    extend ChunkyPNG::Color
  end
end

def function(value)
  MockColour::compose_quick(value, value)
end

def expected
  0x8101876
end
