# Copyright (c) 2014 Oracle and/or its affiliates. All rights reserved. This
# code is released under a tri EPL/GPL/LGPL license. You can use it,
# redistribute it and/or modify it under the terms of the:
# 
# Eclipse Public License version 1.0
# GNU General Public License version 2
# GNU Lesser General Public License version 2.1

REPS = 30

REPS.times do
  v = value
  start = Time.now
  result = sample(v)
  puts "time: #{Time.now - start}"

  unless check(result)
    puts "incorrect"
    exit
  end
end
