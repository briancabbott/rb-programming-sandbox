# Copyright (c) 2014 Oracle and/or its affiliates. All rights reserved. This
# code is released under a tri EPL/GPL/LGPL license. You can use it,
# redistribute it and/or modify it under the terms of the:
# 
# Eclipse Public License version 1.0
# GNU General Public License version 2
# GNU Lesser General Public License version 2.1

SMALL_PRIME = 149

def sample(value)
  sum = 0

  iterations.times do
    sum = (sum + function(value)) % SMALL_PRIME
  end

  sum
end

def check(sum)
  expected_sum = 0

  iterations.times do
    expected_sum = (expected_sum + expected) % SMALL_PRIME
  end

  sum == expected_sum
end
