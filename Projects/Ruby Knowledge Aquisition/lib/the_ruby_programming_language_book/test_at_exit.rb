count = 0
100.times { 
  count += 1
  puts "Hello, world: #{count}"
}

at_exit { 
  puts "goodbye world" 
}
