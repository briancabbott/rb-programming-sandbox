# Licence and Copyright

These scripts are part of JRuby.

Copyright (c) 2014 Oracle and/or its affiliates. All rights reserved. This
code is released under a tri EPL/GPL/LGPL license. You can use it,
redistribute it and/or modify it under the terms of the:

Eclipse Public License version 1.0
GNU General Public License version 2
GNU Lesser General Public License version 2.1

# Use

You need a unix-style system with basic system and compiler tools. Install a
recent version of `rbenv` and `ruby-build`. Use that to install `2.1.2`,
`rbx-2.2.10`, `topaz-dev` and `jruby-1.7.13`. You need Graal 0.3 and a
checkout of JRuby master in the parent directory. On the Mac you will probably
need to use something like Homebrew to install `libxml2`

Run `ruby setup.rb` to check all of this and download and build the gems we
use.

Run `ruby run.rb`. This will probably take several days. You can stop and
start it without problem.

Run `ruby analyse.rb`. This will produce the graphs.

This repository comes with out experiment data in place. Running `run.rb` will
overwrite that.
