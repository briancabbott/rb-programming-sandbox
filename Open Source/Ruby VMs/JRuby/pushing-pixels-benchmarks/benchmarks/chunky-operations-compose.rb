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
  require "chunky_png"
end

PIXEL = 0x12345678

class MockCanvas
  if defined? NATIVE
    puts "native"
    include OilyPNG::Operations
  else
    include ChunkyPNG::Canvas::Operations
    puts "ruby"
  end

  public :compose!

  def initialize
    @pixels = Array.new(width * height)

    @pixels.size.times do |n|
      @pixels[n] = PIXEL
    end
  end

  def width
    2000
  end

  def height
    2000
  end

  def pixels
    @pixels
  end

  def get_pixel(x, y)
    @pixels[y * width + x]
  end

  def set_pixel(x, y, color)
    @pixels[y * width + x] = color
  end
end

def value
  [MockCanvas.new, MockCanvas.new]
end

def sample(value)
  onto, compose = value
  onto.compose!(compose, 0, 0)
  onto
end

def check(result)
  result.pixels.inject(:+) == 882178784000000
end
