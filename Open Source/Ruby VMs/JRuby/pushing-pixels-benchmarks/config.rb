# Copyright (c) 2014 Oracle and/or its affiliates. All rights reserved. This
# code is released under a tri EPL/GPL/LGPL license. You can use it,
# redistribute it and/or modify it under the terms of the:
# 
# Eclipse Public License version 1.0
# GNU General Public License version 2
# GNU Lesser General Public License version 2.1

REPS = 30 # Also change in harness.rb
WARMUP = 15

WD = Dir.pwd

CONFIGURATIONS = [
  "mri",
  "mri-native",
  "rbx",
  "rbx-native",
  "topaz",
  "jruby",
  "jruby+truffle"
]

FULL_NAMES = {
  "mri" => "MRI",
  "mri-native" => "MRI + C Extension",
  "rbx" => "Rubinius",
  "rbx-native" => "Rubinius + C Extension",
  "topaz" => "Topaz",
  "jruby" => "JRuby",
  "jruby+truffle" => "JRuby+Truffle"
}

CHUNKY_BENCHMARKS = [
  "chunky-canvas-resampling-steps-residues",
  "chunky-canvas-resampling-steps",
  "chunky-canvas-resampling-nearest-neighbor",
  "chunky-canvas-resampling-bilinear",
  "chunky-decode-png-image-pass",
  "chunky-encode-png-image-pass-to-stream",
  "chunky-color-compose-quick",
  "chunky-color-r",
  "chunky-color-g",
  "chunky-color-b",
  "chunky-color-a",
  "chunky-operations-compose",
  "chunky-operations-replace"
]

CHUNKY_CONFIGURATIONS = [
  ["mri", "~/.rbenv/versions/2.1.2/bin/ruby --disable=gems -Ichunky_png/lib"],
  ["mri-native", "~/.rbenv/versions/2.1.2/bin/ruby --disable=gems -Ichunky_png/lib -Ioily_png_mri/lib -rnative"],
  ["rbx", "~/.rbenv/versions/rbx-2.2.10/bin/ruby --disable-gems -Ichunky_png/lib -rchunky_png"],
  ["rbx-native", "~/.rbenv/versions/rbx-2.2.10/bin/ruby --disable-gems -Ichunky_png/lib -Ioily_png_rbx/lib -rnative"],
  ["topaz", "~/.rbenv/versions/topaz-dev/bin/ruby -Ichunky_png/lib"],
  ["jruby", "~/.rbenv/versions/jruby-1.7.13/bin/ruby --disable-gems -J-Xmx1G --server -Xcompile.invokedynamic=true -Ichunky_png/lib"],
  ["jruby+truffle", "JAVACMD=../graalvm-jdk1.8.0/bin/java ../jruby/bin/jruby -J-server -J-G:+TruffleCompilationExceptionsAreFatal -J-Xmx1G -X+T -Xtruffle.arrays.int=false -Ichunky_png/lib"]
]

PSD_BENCHMARKS = [
  "psd-imagemode-rgb-combine-rgb-channel",
  "psd-imagemode-cmyk-combine-cmyk-channel",
  "psd-imagemode-greyscale-combine-greyscale-channel",
  "psd-imageformat-rle-decode-rle-channel",
  "psd-imageformat-layerraw-parse-raw",
  "psd-color-cmyk-to-rgb",
  "psd-compose-normal",
  "psd-compose-darken",
  "psd-compose-multiply",
  "psd-compose-color-burn",
  "psd-compose-linear-burn",
  "psd-compose-lighten",
  "psd-compose-screen",
  "psd-compose-color-dodge",
  "psd-compose-linear-dodge",
  "psd-compose-overlay",
  "psd-compose-soft-light",
  "psd-compose-hard-light",
  "psd-compose-vivid-light",
  "psd-compose-linear-light",
  "psd-compose-pin-light",
  "psd-compose-hard-mix",
  "psd-compose-difference",
  "psd-compose-exclusion",
  "psd-renderer-clippingmask-apply",
  "psd-renderer-mask-apply",
  "psd-renderer-blender-compose",
  "psd-util-clamp",
  "psd-util-pad2",
  "psd-util-pad4"
]

PSD_CONFIGURATIONS = [
  ["mri", "~/.rbenv/versions/2.1.2/bin/ruby --disable=gems -Ichunky_png/lib -Ipsd.rb/lib"],
  ["mri-native", "~/.rbenv/versions/2.1.2/bin/ruby --disable=gems -Ichunky_png/lib -Ipsd.rb/lib -Ioily_png_mri/lib -Ipsd_native_mri/lib -rnative"],
  ["rbx", "~/.rbenv/versions/rbx-2.2.10/bin/ruby --disable-gems -Ichunky_png/lib -Ipsd.rb/lib"],
  ["rbx-native", "~/.rbenv/versions/rbx-2.2.10/bin/ruby --disable-gems -Ichunky_png/lib -Ipsd.rb/lib -Ioily_png_rbx/lib -Ipsd_native_rbx/lib -rnative"],
  ["topaz", "~/.rbenv/versions/topaz-dev/bin/ruby -Ichunky_png/lib -Ipsd.rb/lib"],
  ["jruby", "~/.rbenv/versions/jruby-1.7.13/bin/ruby --disable-gems -J-Xmx1G --server -Xcompile.invokedynamic=true -Ichunky_png/lib -Ipsd.rb/lib"],
  ["jruby+truffle", "JAVACMD=../graalvm-jdk1.8.0/bin/java ../jruby/bin/jruby -J-server -J-G:+TruffleCompilationExceptionsAreFatal -J-Xmx1G -X+T -Xtruffle.arrays.int=false -Ichunky_png/lib -Ipsd.rb/lib"]
]

IGNORES = [
  # Produces a different result to other implementations
  ["mri-native", "psd-renderer-mask-apply"],

  # These all never seem to make any progress - gave each several hours and no output
  ["rbx-native", "psd-imageformat-rle-decode-rle-channel"],
  ["rbx-native", "psd-renderer-blender-compose"],
  ["rbx-native", "psd-renderer-mask-apply"],

  # Topaz can't load these - probably due to #pack and #unpack
  ["topaz", "chunky-decode-png-image-pass"],
  ["topaz", "chunky-encode-png-image-pass-to-stream"],
  ["topaz", "chunky-operations-compose"],
  ["topaz", "chunky-operations-replace"]
]

BENCHMARKS = CHUNKY_BENCHMARKS + PSD_BENCHMARKS
