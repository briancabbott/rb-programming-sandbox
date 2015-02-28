# Copyright (c) 2014 Oracle and/or its affiliates. All rights reserved. This
# code is released under a tri EPL/GPL/LGPL license. You can use it,
# redistribute it and/or modify it under the terms of the:
# 
# Eclipse Public License version 1.0
# GNU General Public License version 2
# GNU Lesser General Public License version 2.1

if defined? NATIVE
  require "oily_png/oily_png"
else
  require "chunky_png/canvas/resampling"
end

class MockCanvas
  if defined? NATIVE
    puts "native"
    include OilyPNG::Resampling
  else
    include ChunkyPNG::Canvas::Resampling
    puts "ruby"
  end

  public :steps
end

def value
  MockCanvas.new
end

def sample(value)
  value.steps(1_000_000, 5_000_000)
end

def check(result)
  result.inject(:+) == 2499997500000
end
