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
end

WIDTH = 2000
HEIGHT = 2000
COLOR_MODE = ChunkyPNG::COLOR_TRUECOLOR_ALPHA
DEPTH = 8
PIXEL = 0x12345678
ENCODE_REPS = 100

PIXELS = [PIXEL] * WIDTH * HEIGHT

class MockCanvas
  include ChunkyPNG::Canvas::PNGEncoding

  # I can't seem to lookup this constant correctly
  Color = ChunkyPNG::Color

  if defined? NATIVE
    puts "native"
    include OilyPNG::PNGEncoding
  else
    puts "ruby"
  end

  public :encode_png_image_pass_to_stream

  def initialize
    @pixels = PIXELS
  end

  def width
    WIDTH
  end

  def height
    HEIGHT
  end

  def pixels
    @pixels
  end

  def row(y)
    pixels.slice(y * width, width)
  end
end

def value
  MockCanvas.new
end

def sample(value)
  stream = nil
  
  ENCODE_REPS.times do
    stream = ""
    value.encode_png_image_pass_to_stream(stream, COLOR_MODE, DEPTH, ChunkyPNG::FILTER_NONE)
  end
  
  stream
end

def check(result)
  result.sum == 46080
end
