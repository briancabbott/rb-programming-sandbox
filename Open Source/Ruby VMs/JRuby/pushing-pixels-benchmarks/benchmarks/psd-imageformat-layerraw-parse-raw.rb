# Copyright (c) 2014 Oracle and/or its affiliates. All rights reserved. This
# code is released under a tri EPL/GPL/LGPL license. You can use it,
# redistribute it and/or modify it under the terms of the:
# 
# Eclipse Public License version 1.0
# GNU General Public License version 2
# GNU Lesser General Public License version 2.1

require "mock-logger"

if defined? NATIVE
  require "psd_native/psd_native"
else
  require "chunky_png/color"
  require "psd/color"
  require "psd/util"
  require "psd/image_formats/layer_raw"
end

SIZE = 10_000_000

BYTE = "\x12"
BYTES = BYTE * SIZE

class MockFile
  def read(n)
    if n == 1
      BYTE
    else
      BYTES
    end
  end
end

class MockImage
  if defined? NATIVE
    puts "native"
    include PSDNative::ImageFormat::LayerRAW
  else
    include PSD::ImageFormat::LayerRAW
    puts "ruby"
  end

  public :parse_raw!

  def initialize
    @ch_info = {:length => SIZE}
    @chan_pos = 0
    @file = MockFile.new
    @channel_data = [0] #MG: avoid null arrays
  end

  def channel_data
    @channel_data
  end
end

def value
  MockImage.new
end

def sample(value)
  value.parse_raw!
  value
end

def check(result)
  result.channel_data.inject(:+) == 179999964
end
