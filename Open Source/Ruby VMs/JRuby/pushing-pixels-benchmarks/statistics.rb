# Copyright (c) 2014 Oracle and/or its affiliates. All rights reserved. This
# code is released under a tri EPL/GPL/LGPL license. You can use it,
# redistribute it and/or modify it under the terms of the:
# 
# Eclipse Public License version 1.0
# GNU General Public License version 2
# GNU Lesser General Public License version 2.1

module Perfer
  class Statistics
    def product
      @product ||= @sample.inject(1.0) { |product, i| product * i }
    end

    def geomean
      @geomean ||= product ** (1.0/size)
    end
  end
end
