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
require "psd/renderer/compose"
require "psd/renderer/blender"

if defined? NATIVE
  require "psd_native/psd_native"
end

SIZE = 1_000
PIXEL = 0x11223344

class MockNode
  def blending_mode
    "normal"
  end

  def debug_name
    "name"
  end
end

class MockCanvas
  def initialize
    @pixels = [PIXEL] * SIZE * SIZE
    @node = MockNode.new
  end

  def top
    SIZE
  end

  def left
    SIZE
  end

  def width
    SIZE
  end

  def height
    SIZE
  end

  def pixels
    @pixels
  end

  def [](x, y)
    @pixels[y * SIZE + x]
  end

  def []=(x, y, pixel)
    @pixels[y * SIZE + x] = pixel
  end

  def canvas
    self
  end

  attr_reader :node
end

class MockBlender < PSD::Renderer::Blender
  if defined? NATIVE
    include PSDNative::Renderer::Blender
    puts "native"
  else
    puts "ruby"
  end

  public :compose!

  def initialize
    @fg = MockCanvas.new
    @bg = MockCanvas.new
    @opacity = 128
    @fill_opacity = 128
  end
end

def value
  MockBlender.new
end

def sample(value)
  value.compose!
  value
end

def check(result)
  result.bg.pixels.inject(:+) == 287454032000000
end