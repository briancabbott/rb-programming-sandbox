# Copyright (c) 2014 Oracle and/or its affiliates. All rights reserved. This
# code is released under a tri EPL/GPL/LGPL license. You can use it,
# redistribute it and/or modify it under the terms of the:
# 
# Eclipse Public License version 1.0
# GNU General Public License version 2
# GNU Lesser General Public License version 2.1

require "mock-logger"

require "chunky_png/color"
require "psd/color"
require "psd/util"
require "psd/image_modes/cmyk"

if defined? NATIVE
  require "psd_native/psd_native"
end

WIDTH = 1000
HEIGHT = 1000

CHANNEL_DATA = [128] * WIDTH * HEIGHT * 5

class MockImage
  include PSD::ImageMode::CMYK

  if defined? NATIVE
    puts "native"
    include PSDNative::ImageMode::CMYK
  else
    puts "ruby"
  end

  public :combine_cmyk_channel

  def initialize
    @num_pixels = WIDTH * HEIGHT
    @channels_info = [{id: 0}, {id: 1}, {id: 2}, {id: 3}, {id: -1}]
    @channel_length = @num_pixels
    @channel_data = CHANNEL_DATA
    @pixel_data = []
  end

  def pixel_step
    1
  end

  def pixel_data
    @pixel_data
  end
end

def value
  MockImage.new
end

def sample(value)
  value.combine_cmyk_channel
  value
end

def check(result)
  result.pixel_data.inject(:+) == 1094795648000000
end
