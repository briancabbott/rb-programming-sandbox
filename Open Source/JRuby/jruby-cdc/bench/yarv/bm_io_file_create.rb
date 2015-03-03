<<<<<<< HEAD
#
# Create files
#

max = 50_000
file = './tmpfile_of_bm_io_file_create'

max.times{
  f = open(file, 'w')
  f.close#(true)
}
File.unlink(file)

=======
#
# Create files
#

max = 50_000
file = './tmpfile_of_bm_io_file_create'

max.times{
  f = open(file, 'w')
  f.close#(true)
}
File.unlink(file)

>>>>>>> c348867bba82f393fba910b694a77b4685430155
