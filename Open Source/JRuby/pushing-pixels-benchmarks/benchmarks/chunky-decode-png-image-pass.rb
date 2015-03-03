# Copyright (c) 2014 Oracle and/or its affiliates. All rights reserved. This
# code is released under a tri EPL/GPL/LGPL license. You can use it,
# redistribute it and/or modify it under the terms of the:
# 
# Eclipse Public License version 1.0
# GNU General Public License version 2
# GNU Lesser General Public License version 2.1

require "chunky_png"

if defined? NATIVE
  require "oily_png/oily_png"
else
  require "chunky_png"
end

WIDTH = 2000
HEIGHT = 2000
COLOR_MODE = ChunkyPNG::COLOR_TRUECOLOR_ALPHA
DEPTH = 8
PIXEL = 0x12345678

class MockCanvas
  extend ChunkyPNG::Canvas::PNGDecoding
  if defined? NATIVE
    puts "native"
    include OilyPNG::PNGDecoding
  else
    include ChunkyPNG::Canvas::PNGDecoding
    puts "ruby"
  end

  class << self
    public :decode_png_image_pass
  end

  def initialize(width, height, pixels)
    @width = width
    @height = height
    @pixels = pixels
  end

  def width
    @width
  end

  def height
    @height
  end

  def pixels
    @pixels
  end
end

def value
  pixel = [PIXEL].pack("N")
  scan_line = [ChunkyPNG::FILTER_NONE].pack("c") + (pixel * WIDTH)
  scan_line * HEIGHT
end

def sample(value)
  MockCanvas::decode_png_image_pass(value, WIDTH, HEIGHT, COLOR_MODE, DEPTH, 0)
end

def check(result)
  result.pixels.inject(:+) == 1221679584000000
end
