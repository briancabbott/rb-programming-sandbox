# Copyright (c) 2014 Oracle and/or its affiliates. All rights reserved. This
# code is released under a tri EPL/GPL/LGPL license. You can use it,
# redistribute it and/or modify it under the terms of the:
# 
# Eclipse Public License version 1.0
# GNU General Public License version 2
# GNU Lesser General Public License version 2.1

require "mock-logger"

require "psd/image_formats/rle"

if defined? NATIVE
  require "psd_native/psd_native"
else
  require "chunky_png/color"
  require "psd/color"
  require "psd/util"
end

SIZE = 150
STREAM = "\x04\x12\x34\x56\x78\x90\xFB\x11" * SIZE * SIZE

class MockFile
  def initialize
    @position = 0
  end

  def tell
    @position
  end

  def read(n)
    value = STREAM.slice(@position, @position + n)
    @position += n
    value
  end
end

class MockImage
  include PSD::ImageFormat::RLE

  if defined? NATIVE
    puts "native"
    include PSDNative::ImageFormat::RLE
  else
    puts "ruby"
  end

  public :decode_rle_channel

  def initialize
    @byte_counts = [SIZE] * height
    @line_index = 0
    @chan_pos = 0
    @file = MockFile.new
    @channel_data = [0]
  end

  def height
    SIZE
  end

  def channel_data
    @channel_data
  end
end

def value
  MockImage.new
end

def sample(value)
  value.decode_rle_channel
  value
end

def check(result)
  result.channel_data.inject(:+) == 1487598
end
