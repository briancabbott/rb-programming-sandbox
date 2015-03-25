<<<<<<< HEAD
#
# Seek and Write file.
#

require 'tempfile'

max = 20_000
str = "Hello world!  " * 1000
f = Tempfile.new('yarv-benchmark')

max.times{
  f.seek 0
  f.write str
}
=======
#
# Seek and Write file.
#

require 'tempfile'

max = 20_000
str = "Hello world!  " * 1000
f = Tempfile.new('yarv-benchmark')

max.times{
  f.seek 0
  f.write str
}
>>>>>>> c348867bba82f393fba910b694a77b4685430155
